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
from dotenv import load_dotenv

load_dotenv()  # Reads .env file in the current working directory

# ----------------------------------------------------------
# STEP 2: Import FastAPI and CORS middleware
# FastAPI is the web framework that handles HTTP requests.
# CORSMiddleware allows the Flutter web app (running on a
# different port/domain) to call this backend without
# being blocked by the browser's same-origin policy.
# ----------------------------------------------------------
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

# ----------------------------------------------------------
# STEP 3: Import Firebase Admin SDK
# firebase_admin is used to authenticate with Google Firebase
# services (Firestore database, Cloud Storage, etc.) from
# the server side using a service account JSON key file.
# ----------------------------------------------------------
import firebase_admin
from firebase_admin import credentials

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

# ----------------------------------------------------------
# STEP 5: Create the FastAPI application instance
# This object is the core of our backend. We attach
# routes (endpoints) and middleware to it.
# ----------------------------------------------------------
app = FastAPI(
    title="ASTRA AI Backend",
    description="Sports media piracy detection system backend",
    version="1.0.0"
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
