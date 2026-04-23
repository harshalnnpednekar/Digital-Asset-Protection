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
from contextlib import asynccontextmanager
from dotenv import load_dotenv

from scanner_pipeline import process_scraped_video
from media_processor import extract_frames
from vectorizer import generate_video_vector

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

ALREADY_SCANNED_FILES = set()

load_dotenv()  # Reads .env file in the current working directory

# ----------------------------------------------------------
# STEP 2: Import FastAPI and CORS middleware
# FastAPI is the web framework that handles HTTP requests.
# CORSMiddleware allows the Flutter web app (running on a
# different port/domain) to call this backend without
# being blocked by the browser's same-origin policy.
# ----------------------------------------------------------
from fastapi import FastAPI, UploadFile, File, Form
from fastapi.middleware.cors import CORSMiddleware

# ----------------------------------------------------------
# STEP 3: Import Firebase Admin SDK
# firebase_admin is used to authenticate with Google Firebase
# services (Firestore database, Cloud Storage, etc.) from
# the server side using a service account JSON key file.
# ----------------------------------------------------------
import firebase_admin
from firebase_admin import credentials, firestore, storage

# ----------------------------------------------------------
# STEP 4: Initialize Firebase Admin SDK
# We read the path to the service account JSON file from
# the FIREBASE_CREDENTIALS_PATH environment variable.
# This file contains private keys that authenticate our
# backend with Firebase — NEVER commit it to git.
# ----------------------------------------------------------
firebase_creds_path = os.getenv("FIREBASE_CREDENTIALS_PATH")

# Only initialize if the credentials file actually exists
# This prevents crashes during initial setup before the
# user has placed their firebase_credentials.json file
if firebase_creds_path and os.path.exists(firebase_creds_path):
    cred = credentials.Certificate(firebase_creds_path)
    firebase_admin.initialize_app(cred)
    print("✅ Firebase Admin SDK initialized successfully!")
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

                process_scraped_video(video_path, metadata)

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
    allow_credentials=True,    # Allow cookies and auth headers
    allow_methods=["*"],       # Allow all HTTP methods (GET, POST, PUT, DELETE, etc.)
    allow_headers=["*"],       # Allow all HTTP headers
)

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

@app.post("/processasset")
async def process_asset(
    video_file: UploadFile = File(...),
    distribution_target: str = Form(...)
):
    try:
        db = firestore.client()
        status_ref = db.collection("system_state").document("processing_status")
        
        # Step 1 of 5: Save the uploaded video to a temp directory
        status_ref.set({"current_step": 1, "step_label": "Saving uploaded file"})
        temp_dir = tempfile.mkdtemp(prefix="astra_ingest_")
        temp_video_path = os.path.join(temp_dir, video_file.filename)
        
        # Run synchronous file copy in a background thread
        await asyncio.to_thread(shutil.copyfileobj, video_file.file, open(temp_video_path, "wb"))
            
        # Step 2 of 5: Call extract_frames from media_processor.py
        status_ref.set({"current_step": 2, "step_label": "Extracting video frames"})
        frame_paths = await asyncio.to_thread(extract_frames, temp_video_path, temp_dir)
        
        # Step 3 of 5: Call generate_video_vector from vectorizer.py
        status_ref.set({"current_step": 3, "step_label": "Generating AI fingerprint"})
        vector = await asyncio.to_thread(generate_video_vector, frame_paths)
        if vector is None:
            raise Exception("Failed to generate AI fingerprint (vector returned None)")
            
        # Step 4 of 5: Upload the video file to Firebase Cloud Storage
        status_ref.set({"current_step": 4, "step_label": "Uploading to secure vault"})
        unique_filename = f"{uuid.uuid4()}_{video_file.filename}"
        bucket = storage.bucket()
        blob = bucket.blob(f"vault/{unique_filename}")
        await asyncio.to_thread(blob.upload_from_filename, temp_video_path)
        
        # Step 5 of 5: Write a new document to the Firestore vaulted_assets collection
        status_ref.set({"current_step": 5, "step_label": "Secured and vaulted"})
        
        asset_id = str(uuid.uuid4())
        db.collection("vaulted_assets").document(asset_id).set({
            "asset_name": video_file.filename,
            "distribution_target": distribution_target,
            "vector": vector,
            "storage_path": f"vault/{unique_filename}",
            "status": "VAULTED",
            "created_at": firestore.SERVER_TIMESTAMP
        })
        
        return {
            "success": True,
            "message": "Asset secured successfully",
            "asset_id": asset_id
        }
        
    except Exception as e:
        logging.error(f"Error in /processasset: {e}")
        return {
            "success": False,
            "error": str(e)
        }
    finally:
        if 'temp_dir' in locals():
            shutil.rmtree(temp_dir, ignore_errors=True)

