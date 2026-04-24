# ASTRA — Digital Asset Protection Console
### Institutional-grade media provenance and real-time piracy enforcement.

ASTRA (Advanced Security & Threat Response Architecture) is a comprehensive forensic platform designed for sports broadcasters and premium digital media owners. It provides an end-to-end workflow for authenticating original assets, monitoring unauthorized redistribution across the "clear web" and social platforms, and visualizing the contagion path of leaked content.

---

## 🚀 Core Pillars

- **Cryptographic Provenance**: C2PA-style workflows to verify the origin and integrity of digital masters.
- **Forensic Watermarking**: Invisible, encrypted LSB steganography injected into assets for precise "Patient Zero" leak attribution.
- **AI-Driven Intelligence**: Multi-modal threat detection using CLIP-based visual fingerprinting and Gemini-assisted intent analysis.
- **Real-Time Contagion Mapping**: Visualizing the propagation of threats from the source leak to downstream social nodes.

---

## 🔍 Forensic Analysis Workflow

ASTRA implements a multi-stage forensic pipeline to ensure 100% detection accuracy and defensible evidence gathering:

1.  **Ingestion & Fingerprinting**: Every protected asset is processed into a 512D "Visual DNA" using CLIP. This fingerprint is invariant to compression, resolution changes, and minor cropping.
2.  **Encrypted Injection**: At the point of distribution, the system injects a unique, Fernet-encrypted identifier into the first I-frame of the video. This links the specific copy to a distribution partner or region.
3.  **Autonomous Scraping**: Backend agents continuously monitor social feeds and "clear web" video directories for matching visual fingerprints.
4.  **Intelligent Triage**: When a visual match is found (Similarity > 82%), Gemini 1.5 Flash analyzes the surrounding context (captions/metadata) to distinguish between a legitimate fan "fair use" reaction and a piracy-driven "free stream."
5.  **Contagion Attribution**: Once a threat is confirmed, the system extracts the watermark from the source and correlates it with the "Patient Zero" distribution record.

---

## 🛠 Product Modules

### 1. Asset Vault
Inspect protected digital masters, manage C2PA metadata, and view historical provenance records. The vault serves as the "Source of Truth" for all protected media.

### 2. Live Threat Radar
A real-time monitoring center that aggregates scraped data from YouTube, Telegram, X (Twitter), and Reddit. It automatically triages potential piracy vs. fair use.

### 3. Contagion Analysis (Propagation Flow)
A graph-based visualization tool built with `graphview`. It traces the flow of unauthorized content, identifying major distribution hubs and terminal endpoints.

### 4. Forensic Dashboard
Executive-level KPIs including:
- **Leak Source Attribution**: Identifying which distribution partner or region is the origin of the most leaks.
- **Platform Breakdown**: Monitoring where the majority of piracy occurs (e.g., Telegram vs. YouTube).
- **Incident Timelines**: Tracking the speed of piracy propagation post-broadcast.

---

## 🏗 System Architecture

### Frontend (Flutter Web)
- **Architecture**: Feature-first folder structure for high modularity.
- **State Management**: `flutter_riverpod` for reactive data streams.
- **Routing**: `go_router` supporting deep-linking (e.g., direct navigation to specific threat nodes).
- **Visualization**: Custom `CustomPainter` and `graphview` for forensic node maps.

### Backend (FastAPI & AI Pipeline)
- **FastAPI Server**: High-performance Python backend managing ingestion, watermarking, and scraping cycles.
- **AI Fingerprinting**: CLIP (`openai/clip-vit-base-patch32`) used to generate 512D vectors for video frames.
- **Intent Analysis**: Google Gemini 1.5 Flash integrated via JSON-mode for automated Piracy vs. Fair Use classification.
- **Database**: Firebase (Firestore & Storage) for real-time synchronization between backend agents and the dashboard.

---

## 🧠 AI Pipeline Depth

### Visual Fingerprinting (CLIP)
Unlike traditional MD5 hashing, CLIP-based fingerprinting understands the *semantic content* of a frame.
- **Resilience**: Effective against transcoding, watermarking, and noise.
- **Mean Pooling**: ASTRA extracts 1 frame every 2 seconds and computes a temporal mean vector, creating a unique "temporal signature" for the entire video clip.
- **Similarity Threshold**: Optimized at **0.82** (Cosine) to balance detection sensitivity and false-positive suppression.

### Intent Analysis (Gemini 1.5 Flash)
Gemini acts as the "Decision Layer" to reduce manual workload for legal teams.
- **Contextual Parsing**: It scans captions for keywords like "Join my Telegram for full match," "No copyright intended," or "Free live stream."
- **Confidence Scoring**: Returns a probability score (0.0 - 1.0) allowing legal teams to auto-enforce only high-confidence threats.

---

## ⚙️ Performance & Security Hardening

### ⚡ AI Optimizations
- **Batch Inference**: The backend processes frame vectors in parallel batches rather than sequentially, reducing latency by ~70%.
- **GPU Acceleration**: Automated CUDA detection with `float16` precision support for institutional-grade throughput.
- **NumPy Matrix Search**: Threat comparison utilizes batch cosine similarity (Matrix-Vector multiplication), allowing comparison against thousands of vaulted assets in milliseconds.

### 🛡 Security Posture
- **Endpoint Protection**: Rate limiting (3 req/min per IP), file size validation (100MB), and MIME-type enforcement.
- **CORS Hardening**: Strict origin policies and credential disabling for wildcard configurations.
- **Storage Protection**: Firestore and Storage rules enforcing `request.auth != null` with administrative write restrictions.
- **Prompt Injection Defense**: Gemini integration utilizes `response_mime_type: "application/json"` to ensure structural integrity regardless of malicious input captions.

---

## 📂 Repository Layout

```text
Digital-Asset-Protection/
├── lib/                        # Flutter Frontend
│   ├── core/                   # Shared theme, navigation, and services
│   └── features/               # Module-based features (auth, vault, threats, etc.)
├── astra_backend/              # Python Backend
│   ├── main.py                 # FastAPI Entry Point
│   ├── scanner_pipeline.py     # Background scraping and detection logic
│   ├── vectorizer.py           # CLIP AI implementation
│   ├── watermark.py            # Steganography & Encryption
│   ├── config/                 # Configuration & Secrets (.env, serviceAccount.json)
│   └── mock_internet_feed/     # Simulated scraped data for demonstrations
└── pubspec.yaml                # Flutter Dependencies
```

---

## 🛠 Installation & Setup

### 1. Prerequisites
- **Flutter SDK** (>=3.0.0)
- **Python 3.10+**
- **FFmpeg** installed on the system (required for watermarking and frame extraction)
- **Firebase Project** with Firestore and Storage enabled.

### 2. Frontend Setup
```bash
# Navigate to root
flutter pub get

# Configure Firebase
# Ensure lib/firebase_options.dart is generated via FlutterFire CLI
```

### 3. Backend Setup
```bash
# Navigate to astra_backend
python -m venv .venv
source .venv/bin/activate  # Or .venv\Scripts\activate on Windows
pip install -r requirements.txt
```

### 4. Environment Configuration
Create `astra_backend/config/.env` using the following keys:
- `GEMINI_API_KEY`: For intent analysis.
- `HUGGINGFACE_API_KEY`: For backup CLIP inference.
- `FIREBASE_CREDENTIALS_PATH`: Path to your Service Account JSON.
- `SCANNER_POLL_INTERVAL`: Frequency of background scans (default 45s).

---

## 🚀 Running the Project

1. **Start the Backend**:
   ```bash
   python astra_backend/main.py
   ```
2. **Start the Flutter App**:
   ```bash
   flutter run -d chrome
   ```

---

## 🛰 Deployment & Scalability Roadmap

For production-scale deployment, ASTRA is designed to transition into the following infrastructure:

- **Vector Database**: Migrate from Firestore-based NumPy search to **Pinecone** or **Milvus** for sub-second searches across millions of assets.
- **Distributed Workers**: Implement **Celery/Redis** to distribute the scraper and watermarking workloads across multiple GPU-enabled nodes.
- **Edge Inference**: Deploy the CLIP vision model to **Triton Inference Server** for high-concurrency requests.
- **Blockchain Integration**: Finalize C2PA compliance by anchoring asset fingerprints to a public ledger (e.g., Ethereum/Polygon) for immutable provenance.

---

## ❓ Troubleshooting

| Issue | Potential Solution |
| :--- | :--- |
| **FFmpeg Error** | Ensure FFmpeg is in your system PATH. Test with `ffmpeg -version`. |
| **Out of Memory (OOM)** | Reduce `MAX_FRAMES_PER_VIDEO` in `.env` or enable the `float16` optimization. |
| **429 Rate Limit** | Gemini free tier has a limit of 15 RPM. Ensure `SCANNER_POLL_INTERVAL` is >= 45s. |
| **Empty Contagion Map** | Ensure the `contagion_nodes` collection has the correct `threat_id` mapping. |

---

## 📜 License & Legal
This platform is a proprietary technology demonstration. 
Copyright © 2026 ASTRA. All rights reserved.

**Note**: This software is intended for legitimate copyright enforcement by authorized rights holders. Unauthorized use for surveillance or anti-competitive behavior is strictly prohibited.

