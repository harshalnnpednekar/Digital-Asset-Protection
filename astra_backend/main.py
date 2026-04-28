# ============================================================
# ASTRA AI — Main FastAPI Application
# ============================================================
# This is the entry point for the ASTRA AI backend server.
# It initializes environment variables, Firebase, CORS,
# and exposes a health-check endpoint for the Flutter frontend.
# ============================================================

# ----------------------------------------------------------
# STEP 1: Load environment variables from .env file
# This MUST happen before any other imports that use env vars.
# python-dotenv reads the .env file and injects the key=value
# pairs into os.environ so we can access them with os.getenv().
# ----------------------------------------------------------
import os
import asyncio
import glob
import json
import logging
import tempfile
import shutil
import uuid
import sys
from contextlib import asynccontextmanager
from dotenv import load_dotenv

backend_dir = os.path.dirname(__file__)
if backend_dir not in sys.path:
    sys.path.append(backend_dir)

from scanner_pipeline import process_scraped_video
from media_processor import extract_frames
from vectorizer import generate_video_vector
from watermark import inject_watermark

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

ALREADY_SCANNED_FILES = set()

load_dotenv(dotenv_path=os.path.join(os.path.dirname(__file__), "config", ".env"))

# Security: Rate limiting state
request_history = {}
RATE_LIMIT_SECONDS = 60
MAX_REQUESTS_PER_WINDOW = 3

# ----------------------------------------------------------
# STEP 2: Import FastAPI and CORS middleware
# FastAPI is the web framework that handles HTTP requests.
# CORSMiddleware allows the Flutter web app (running on a
# different port/domain) to call this backend without
# being blocked by the browser's same-origin policy.
# ----------------------------------------------------------
from fastapi import FastAPI, UploadFile, File, Form, Request, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from pydantic import BaseModel
import base64
import ffmpeg
from fastapi.responses import JSONResponse
from cryptography.fernet import Fernet
from stegano import lsb

# ----------------------------------------------------------
# STEP 3: Import Firebase Admin SDK
# firebase_admin is used to authenticate with Google Firebase
# services (Firestore database, Cloud Storage, etc.) from
# the server side using a service account JSON key file.
# ----------------------------------------------------------
import firebase_admin
from firebase_admin import credentials, firestore
# Firebase Storage removed — files are stored locally under uploads/

# ----------------------------------------------------------
# STEP 4: Initialize Firebase Admin SDK
# We read the path to the service account JSON file from
# the FIREBASE_CREDENTIALS_PATH environment variable.
# This file contains private keys that authenticate our
# backend with Firebase — NEVER commit it to git.
# ----------------------------------------------------------
firebase_creds_path = os.getenv("FIREBASE_CREDENTIALS_PATH")
# Local upload root — videos are saved here instead of Firebase Storage
UPLOADS_ROOT = os.path.join(os.path.dirname(__file__), "uploads")
VAULT_DIR    = os.path.join(UPLOADS_ROOT, "vault")
os.makedirs(VAULT_DIR, exist_ok=True)

if firebase_creds_path and not os.path.isabs(firebase_creds_path):
    backend_config_dir = os.path.join(os.path.dirname(__file__), "config")
    candidate_path = os.path.join(backend_config_dir, firebase_creds_path)
    if os.path.exists(candidate_path):
        firebase_creds_path = candidate_path
    else:
        firebase_creds_path = os.path.join(os.path.dirname(__file__), firebase_creds_path)

# Only initialize if the credentials file actually exists
# This prevents crashes during initial setup before the
# user has placed their firebase_credentials.json file
if firebase_creds_path and os.path.exists(firebase_creds_path):
    cred = credentials.Certificate(firebase_creds_path)
    # No storageBucket needed — we use local disk storage now
    firebase_admin.initialize_app(cred)
    print("✅ Firebase Admin SDK initialized (Firestore only, no Storage)")
else:
    print("⚠️  Firebase credentials file not found at:", firebase_creds_path)
    print("   The server will start, but Firebase features won't work.")
    print("   Place your firebase_credentials.json file in the astra_backend/ folder.")

# ==============================================================================
# TO SIMULATE PIRACY DETECTION — drop any .mp4, .mov, .avi, .mkv, or .webm
# video file into any subfolder inside mock_internet_feed and it will be 
# automatically detected within SCANNER_POLL_INTERVAL seconds and processed 
# through the full AI detection pipeline.
# ==============================================================================


async def run_scanner_cycle():
    base_dir = os.path.join(os.path.dirname(__file__), "mock_internet_feed")
    if not os.path.exists(base_dir):
        logging.warning("mock_internet_feed folder not found, skipping scan cycle")
        return

    subfolders = ["youtube_mirror", "telegram_channel", "twitter_feed"]
    extensions = ["*.mp4", "*.mov", "*.avi", "*.mkv", "*.webm"]

    total_files = 0
    processed_this_cycle = 0
    skipped_this_cycle = 0

    for folder_name in subfolders:
        logging.info(f"Scanning subfolder: {folder_name}")
        folder_path = os.path.join(base_dir, folder_name)
        if not os.path.exists(folder_path):
            logging.info(f"{folder_name} subfolder is empty")
            continue

        video_files = []
        for ext in extensions:
            pattern = os.path.join(folder_path, ext)
            video_files.extend(glob.glob(pattern))

        if not video_files:
            logging.info(f"subfolder is empty")
            continue

        total_files += len(video_files)

        for video_path in video_files:
            try:
                size_1 = os.path.getsize(video_path)
                await asyncio.sleep(1)
                size_2 = os.path.getsize(video_path)

                if size_1 != size_2:
                    continue

                if video_path in ALREADY_SCANNED_FILES:
                    skipped_this_cycle += 1
                    continue

                ALREADY_SCANNED_FILES.add(video_path)
                processed_this_cycle += 1

                metadata_path = os.path.join(folder_path, "metadata.json")
                if os.path.exists(metadata_path):
                    with open(metadata_path, 'r', encoding='utf-8') as f:
                        metadata = json.load(f)
                else:
                    logging.warning(f"metadata.json missing in subfolder, using defaults")
                    metadata = {
                        "platform": "Unknown",
                        "caption": "",
                        "uploader": "Unknown",
                        "url": "unknown",
                        "is_suspicious": True
                    }

                await asyncio.to_thread(process_scraped_video, video_path, metadata)

            except Exception as e:
                logging.error(f"Error handling file {video_path}: {e}")
                ALREADY_SCANNED_FILES.add(video_path)

    logging.info(f"Scan cycle summary - Total videos: {total_files}, New processed: {processed_this_cycle}, Skipped: {skipped_this_cycle}")

@asynccontextmanager
async def lifespan(app: FastAPI):
    poll_interval = int(os.getenv("SCANNER_POLL_INTERVAL", "45"))
    
    async def scanner_loop():
        while True:
            await run_scanner_cycle()
            try:
                await asyncio.sleep(poll_interval)
            except Exception as e:
                logging.error(f"Scanner sleep interrupted: {e}")
                continue

    loop_task = asyncio.create_task(scanner_loop())
    yield
    loop_task.cancel()

# ----------------------------------------------------------
# STEP 5: Create the FastAPI application instance
# This object is the core of our backend. We attach
# routes (endpoints) and middleware to it.
# ----------------------------------------------------------
app = FastAPI(
    title="ASTRA AI Backend",
    description="Sports media piracy detection system backend",
    version="1.0.0",
    lifespan=lifespan
)

# ── Static file serving for locally-stored vault videos ──────────────────────
# Vaulted videos are saved to astra_backend/uploads/vault/ and accessible at:
#   GET http://127.0.0.1:8000/uploads/vault/<filename>
# This replaces Firebase Storage download URLs entirely.
app.mount("/uploads", StaticFiles(directory=UPLOADS_ROOT), name="uploads")

# ----------------------------------------------------------
# STEP 6: Add CORS Middleware
# This allows the Flutter web frontend to make API calls
# to this backend. We allow ALL origins, methods, and
# headers because this is a hackathon demo.
# In production, you would restrict allow_origins to
# only your frontend's domain.
# ----------------------------------------------------------
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],       # Allow requests from any origin (domain)
    allow_credentials=False,   # Credentials are not required for these API calls
    allow_methods=["*"],       # Allow all HTTP methods (GET, POST, PUT, DELETE, etc.)
    allow_headers=["*"],       # Allow all HTTP headers
)


def require_firebase_services():
    """Ensures Firestore is available. Storage is local — no bucket check needed."""
    if not firebase_admin._apps:
        raise HTTPException(
            status_code=503,
            detail="Firebase (Firestore) is not configured on this backend.",
        )


def copy_upload_file(source_file, destination_path):
    with open(destination_path, "wb") as destination_file:
        shutil.copyfileobj(source_file, destination_file)

# ----------------------------------------------------------
# STEP 7: Root endpoint — Health Check
# This is a simple GET endpoint at the root URL (/).
# When you open http://localhost:8000 in your browser,
# it returns a JSON response confirming the server is alive.
# The Flutter app can also call this to verify connectivity.
# ----------------------------------------------------------
@app.get("/")
def root():
    """
    Health check endpoint.
    Returns a JSON object confirming the ASTRA AI backend is online.
    """
    return {
        "message": "ASTRA AI Backend Online",
        "health": True
    }

@app.post("/process-asset")
async def process_asset(
    request: Request,
    video_file: UploadFile = File(...),
    distribution_target: str = Form(...),
    asset_name: str = Form(default=""),
    asset_category: str = Form(default="HIGHLIGHT"),
):
    # RATE LIMITING (Test 10)
    client_ip = request.client.host if request.client else "unknown"
    now = asyncio.get_event_loop().time()
    if client_ip not in request_history:
        request_history[client_ip] = []
    request_history[client_ip] = [t for t in request_history[client_ip] if now - t < RATE_LIMIT_SECONDS]
    if len(request_history[client_ip]) >= MAX_REQUESTS_PER_WINDOW:
        return JSONResponse(status_code=429, content={"success": False, "error": "Too many requests. Please wait 60 seconds."})
    request_history[client_ip].append(now)

    # FILE SIZE VALIDATION (Test 3)
    MAX_SIZE = 100 * 1024 * 1024
    video_file.file.seek(0, os.SEEK_END)
    file_size = video_file.file.tell()
    video_file.file.seek(0)
    if file_size > MAX_SIZE:
        return JSONResponse(status_code=413, content={"success": False, "error": "File too large. Maximum 100MB allowed."})

    # FILE TYPE VALIDATION (Test 4)
    ALLOWED_TYPES = ["video/mp4", "video/quicktime", "video/x-msvideo", "video/x-matroska", "video/webm"]
    if video_file.content_type not in ALLOWED_TYPES:
        return JSONResponse(status_code=415, content={"success": False, "error": "Unsupported file type. Only video files are accepted."})

    # EMPTY FIELD VALIDATION (Test 5)
    if not distribution_target or not distribution_target.strip():
        return JSONResponse(status_code=422, content={"success": False, "error": "distribution_target is required and cannot be empty."})

    try:
        require_firebase_services()
        db = firestore.client()
        status_ref = db.collection("system_state").document("processing_status")
        
        # Step 1 of 5: Save the uploaded video to a temp directory
        status_ref.set({"current_step": 1, "step_label": "Saving uploaded file"})
        temp_dir = tempfile.mkdtemp(prefix="astra_ingest_")
        temp_video_path = os.path.join(temp_dir, video_file.filename)
        
        # Run synchronous file copy in a background thread
        await asyncio.to_thread(copy_upload_file, video_file.file, temp_video_path)
            
        # Step 2 of 5: Call extract_frames from media_processor.py
        status_ref.set({"current_step": 2, "step_label": "Extracting video frames"})
        frame_paths = await asyncio.to_thread(extract_frames, temp_video_path, temp_dir)
        
        # Step 3 of 5: Call generate_video_vector from vectorizer.py
        status_ref.set({"current_step": 3, "step_label": "Generating AI fingerprint"})
        vector = await asyncio.to_thread(generate_video_vector, frame_paths)
        if vector is None:
            raise Exception("Failed to generate AI fingerprint (vector returned None)")
            
        # --- NEW SUB-STEP: Inject Cryptographic Watermark ---
        status_ref.set({"current_step": 3.5, "step_label": "Injecting cryptographic watermark"})
        asset_id = str(uuid.uuid4())
        
        watermark_result = await asyncio.to_thread(
            inject_watermark, temp_video_path, distribution_target, asset_id, temp_dir
        )
        
        watermark_key = None
        if watermark_result is not None:
            temp_video_path = watermark_result["watermarked_video_path"]
            watermark_key = watermark_result["encryption_key"]
        else:
            logging.warning("Watermark injection failed. Continuing with original unwatermarked video.")
            
        # Step 4 of 5: Persist watermarked video to local vault storage
        # Previously uploaded to Firebase Storage — now saved to disk to avoid
        # the Blaze billing requirement. File is served via StaticFiles mount.
        status_ref.set({"current_step": 4, "step_label": "Persisting to secure local vault"})
        unique_filename = f"{uuid.uuid4()}_{video_file.filename}"
        vault_file_path = os.path.join(VAULT_DIR, unique_filename)
        await asyncio.to_thread(shutil.copy2, temp_video_path, vault_file_path)
        local_video_url = f"/uploads/vault/{unique_filename}"
        logging.info(f"Video persisted locally: {vault_file_path}")

        # Step 5 of 5: Write a new document to the Firestore vaulted_assets collection
        status_ref.set({"current_step": 5, "step_label": "Secured and vaulted"})
        
        # Resolve display name: use user-supplied name or fall back to filename
        resolved_asset_name = asset_name.strip() if asset_name.strip() else video_file.filename
        resolved_category = asset_category.strip().upper() if asset_category.strip() else "HIGHLIGHT"

        db.collection("vaulted_assets").document(asset_id).set({
            "asset_name": resolved_asset_name,
            "category": resolved_category,
            "distribution_target": distribution_target,
            "vector": vector,
            # local_path: absolute path on disk (used by decrypt-watermark)
            "local_path": vault_file_path,
            # video_url: relative URL served by this backend's /uploads mount
            "video_url": local_video_url,
            "status": "VAULTED",
            "created_at": firestore.SERVER_TIMESTAMP,
            "watermark_key": watermark_key,
            "upload_date": __import__('datetime').datetime.utcnow().strftime("%Y-%m-%d"),
            "file_size": f"{round(file_size / (1024 * 1024), 1)} MB",
        })
        
        return {
            "success": True,
            "message": "Asset secured successfully",
            "asset_id": asset_id
        }
        
    except Exception as e:
        logging.error(f"Error in /process-asset: {e}")
        return {
            "success": False,
            "error": str(e)
        }
    finally:
        if 'temp_dir' in locals():
            shutil.rmtree(temp_dir, ignore_errors=True)

class DecryptRequest(BaseModel):
    asset_id: str

@app.post("/decrypt-watermark")
async def decrypt_watermark(req: DecryptRequest):
    """
    Decrypts the steganographic watermark embedded in a vaulted asset.
    Reads the video directly from local disk (no Firebase Storage needed).
    """
    temp_dir = None
    try:
        require_firebase_services()
        db = firestore.client()
        doc_ref = db.collection("vaulted_assets").document(req.asset_id)
        doc = await asyncio.to_thread(doc_ref.get)
        if not doc.exists:
            return JSONResponse(status_code=404, content={"success": False, "error": "Asset not found"})

        data = doc.to_dict()
        watermark_key = data.get("watermark_key")
        if not watermark_key:
            return {"success": False, "message": "Watermark not available for this asset"}

        # ── Read video from local disk ────────────────────────────────────────
        # Prefer the absolute local_path written at ingest time.
        # Fall back to reconstructing from video_url for older records.
        local_path = data.get("local_path")
        if not local_path or not os.path.exists(local_path):
            # Attempt fallback: reconstruct path from video_url
            video_url = data.get("video_url", "")
            if video_url.startswith("/uploads/vault/"):
                filename = video_url.replace("/uploads/vault/", "")
                local_path = os.path.join(VAULT_DIR, filename)

        if not local_path or not os.path.exists(local_path):
            return JSONResponse(
                status_code=404,
                content={"success": False, "error": "Vaulted video file not found on disk. It may have been cleaned up."}
            )

        temp_dir = tempfile.mkdtemp(prefix="astra_decrypt_")
        temp_image_path = os.path.join(temp_dir, "frame.png")

        # Extract first frame from the locally-stored video
        (
            ffmpeg
            .input(local_path)
            .filter('select', 'eq(n,0)')
            .output(temp_image_path, vframes=1, format='image2', vcodec='png')
            .overwrite_output()
            .run(capture_stdout=True, capture_stderr=True)
        )

        base64_str = await asyncio.to_thread(lsb.reveal, temp_image_path)
        if not base64_str:
            raise Exception("No watermark found in image")

        ciphertext_bytes = base64.b64decode(base64_str)
        f = Fernet(watermark_key.encode('utf-8'))
        decrypted_bytes = f.decrypt(ciphertext_bytes)
        payload = json.loads(decrypted_bytes.decode('utf-8'))

        return {
            "success": True,
            "patient_zero": payload.get("distribution_target", "Unknown"),
            "asset_id": payload.get("asset_id", "Unknown")
        }

    except Exception as e:
        logging.error(f"Error in /decrypt-watermark: {e}")
        return JSONResponse(status_code=500, content={"success": False, "error": str(e)})
    finally:
        if temp_dir and os.path.isdir(temp_dir):
            shutil.rmtree(temp_dir, ignore_errors=True)


if __name__ == "__main__":
    import uvicorn

    uvicorn.run(app, host="0.0.0.0", port=int(os.getenv("PORT", "8000")), reload=True)
