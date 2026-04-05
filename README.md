# ASTRA - Digital Asset Protection Console

Institutional-grade media provenance and real-time piracy enforcement for sports broadcasting and premium digital media.

ASTRA (app package name: `sentinel_ai`) is a Flutter-based command dashboard that helps teams authenticate assets, monitor unauthorized redistribution, and track threat propagation.

## Overview

This project combines:

- A Flutter web interface for operational monitoring and reporting.
- Firebase services for authentication, storage, and data operations.
- A small Python Firebase Admin helper under `astra_backend/`.

## Core Pillars

1. Cryptographic authenticity (C2PA-style provenance workflows).
2. Robust watermarking concepts for leak attribution.
3. AI-assisted threat detection and triage workflows.

## Product Modules

- Asset Vault: inspect protected digital masters and related metadata.
- Live Threat Radar: monitor active threats and queue enforcement actions.
- Contagion Analysis: visualize spread patterns from origin to downstream nodes.
- Dashboard: KPIs, platform breakdowns, timelines, and incident tables.

## Tech Stack

- Flutter / Dart (`>=3.0.0 <4.0.0`)
- `flutter_riverpod` for state management
- `go_router` for routing and shell navigation
- Firebase (`firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_storage`)
- `dio`, `file_picker`, `intl`, `uuid`
- Python `firebase-admin` helper script (`astra_backend/main.py`)

## Repository Layout

```text
lib/
   core/
      navigation/
      services/
      theme/
      widgets/
   features/
      auth/
      dashboard/
      threats/
      vault/
      contagion/
      settings/
astra_backend/
   main.py
   requirements.txt
   config/
      serviceAccountKey.json
```

## Getting Started (Flutter App)

### 1. Prerequisites

- Flutter SDK installed
- Chrome (or another web target) for local runs
- Firebase project configured for your environment

Check Flutter setup:

```bash
flutter doctor
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Configure Environment Files

The app loads env values from `astra_backend/config/.env` at startup.

- Create `astra_backend/config/.env` if it does not exist.
- Add any variables your local setup requires.

Also ensure Firebase options are present in:

- `lib/config/firebase_options.dart`
- `lib/firebase_options.dart` (if your flow uses both)

### 4. Run the App

```bash
flutter run -d chrome
```

For release-style web build:

```bash
flutter build web
```

## Backend Helper (Python Firebase Admin)

The `astra_backend/main.py` script initializes Firebase Admin SDK and creates collection references used by backend workflows.

### Setup

```bash
python -m venv .venv
.venv\Scripts\activate
pip install -r astra_backend/requirements.txt
```

### Run

```bash
python astra_backend/main.py
```

Before running, place your Firebase service account key at:

`astra_backend/config/serviceAccountKey.json`

## Notes

- Current UI includes demo-oriented screens and mock data sources in multiple features.
- Keep credentials and key files out of version control.

## License

Internal use only. Copyright (c) 2026 ASTRA. All rights reserved.
