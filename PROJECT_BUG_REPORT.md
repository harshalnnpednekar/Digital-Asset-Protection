# ASTRA Project — Comprehensive Bug Report

Date: 2026-04-24  
Repository: Digital-Asset-Protection  
Analysis: Full static code audit — backend (FastAPI/Python) + frontend (Flutter/Dart) + cross-cutting integration

---

## Severity Legend

| Severity | Definition |
|----------|-----------|
| **CRITICAL** | Blocks compilation, exposes secrets, or breaks core data flow |
| **HIGH** | Major reliability/security/integration failure |
| **MEDIUM** | Incorrect behavior, UX mismatch, or tech debt with user impact |
| **LOW** | Minor issues, dead code, or polish gaps |

---

## CRITICAL ISSUES

### C-1. Firebase Service Account Private Key Committed to Disk

- **File:** `astra_backend/config/serviceAccountKey.json:5`
- **Problem:** Full private key material (`-----BEGIN PRIVATE KEY-----\nMIIEvA...`) is present in plaintext along with `private_key_id`, `client_email`, and `project_id`.
- **Note:** `.gitignore` excludes `astra_backend/config/` so the file is not tracked in git, but the real key still exists on disk and was clearly used during development. If this repo was ever pushed with a different `.gitignore` state or shared as a zip, the key is compromised.
- **Impact:** Full admin access to Firestore, Cloud Storage, and IAM for project `solution-gdg`. Credential abuse, data exfiltration, and resource hijacking are all possible.
- **Fix:** Immediately rotate/revoke the key in GCP Console → IAM → Service Accounts. Never store keys on disk — use environment variables or GCP Secret Manager.

### C-2. Firebase Web Config Hardcoded in Committed `.env` Template

- **File:** `astra_backend/config/.env:59-65`
- **Problem:** Real Firebase web app config values (`apiKey=[REDACTED]`, `appId`, `messagingSenderId`, `measurementId`) are hardcoded in the `.env` template file — the same file that is supposed to be a "copy and fill in" template (see comment at line 5).
- **Impact:** Anyone reading this template gets real Firebase project identifiers. Combined with C-1, this completes the attack surface.
- **Fix:** Replace all real values with `YOUR_*_HERE` placeholders in the template.

### C-3. Flutter App Bundles Backend `.env` as a Client-Side Asset

- **File:** `pubspec.yaml:56` → `assets: - astra_backend/config/.env`
- **File:** `lib/main.dart:16` → `await dotenv.load(fileName: "astra_backend/config/.env");`
- **Problem:** The backend environment file (containing API keys, Firebase config, Ngrok tokens) is bundled directly into the Flutter web build as a client-side asset. Any user can open DevTools → Sources and read every secret.
- **Impact:** All backend secrets (HuggingFace, Gemini, Firebase, Ngrok) are exposed to the browser.
- **Fix:** Separate frontend-safe config (Firebase web config only) from backend-only secrets. Never bundle server-side `.env` files as Flutter assets.

### C-4. Flutter Compilation Error — Deprecated `urlPathStrategy`

- **File:** `lib/core/navigation/app_router.dart:51`
- **Problem:** `urlPathStrategy: UrlPathStrategy.hash` is not a valid parameter for `GoRouter` in `go_router: ^13.0.0`. The `UrlPathStrategy` enum and `urlPathStrategy` named parameter were removed in go_router v6+.
- **Impact:** Project fails to compile. `flutter build` and `flutter run` both fail.
- **Fix:** Remove line 51 entirely. For hash-based URL strategy, use `GoRouter.optionURLReflectsImperativeAPIs = true;` or call `usePathUrlStrategy()` from `package:flutter_web_plugins` before `runApp()`.

### C-5. Frontend-Backend API Route Mismatch — Upload Always 404s

- **Frontend:** `lib/features/vault/widgets/upload_modal.dart:80` → `POST ${ApiConfig.backendBaseUrl}/process-asset`
- **Backend:** `astra_backend/main.py:228` → `@app.post("/processasset")`
- **Problem:** Frontend sends to `/process-asset` (hyphenated), backend listens on `/processasset` (no hyphen). Every upload request returns HTTP 404.
- **Impact:** The entire asset vaulting pipeline is broken — no file can be ingested, watermarked, vectorized, or stored.
- **Fix:** Rename backend route to `/process-asset` or update frontend to `/processasset`. Must be consistent.

---

## HIGH ISSUES

### H-1. Backend Has No Runnable Entrypoint

- **File:** `astra_backend/main.py` — no `if __name__ == "__main__":` block, no `uvicorn.run()` call.
- **README says:** `python astra_backend/main.py` (this does nothing useful — it runs module-level imports but does not start an HTTP server).
- **Impact:** Following documentation does not start the API server. Frontend cannot reach backend.
- **Fix:** Add `if __name__ == "__main__": uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)` or update docs to: `uvicorn astra_backend.main:app --reload`.

### H-2. API Base URL is a Placeholder String

- **File:** `lib/config/api_config.dart:17` → `static const String backendBaseUrl = 'https://YOUR-NGROK-URL.ngrok-free.app';`
- **Impact:** All HTTP calls from the Flutter app fail immediately. No validation or fallback exists.
- **Fix:** Use `flutter_dotenv` or compile-time `--dart-define` to inject the URL. Add a startup check that fails fast if the URL contains `YOUR-`.

### H-3. Watermark Temp Files Use Static Global Paths — Race Condition

- **File:** `astra_backend/watermark.py:41-43`
- **Problem:** Hardcoded paths `temp/frame_to_mark.png`, `temp/frame_marked.png`, `temp/watermarked_video.mp4`. All concurrent requests write to the same files.
- **Impact:** Two simultaneous uploads corrupt each other's watermark frames, producing wrong forensic attribution or broken video output.
- **Fix:** Use `tempfile.mkdtemp()` per invocation (like `scanner_pipeline.py` already does at line 16).

### H-4. Firebase Init is Optional But All Endpoints Assume It Succeeded

- **File:** `astra_backend/main.py:79-86` — logs a warning and continues if creds are missing.
- **File:** `astra_backend/main.py:262, 301, 340, 357` — calls `firestore.client()` and `storage.bucket()` unconditionally.
- **Impact:** If Firebase init failed, every API call crashes with an uninitialized SDK error. The warning is swallowed at startup.
- **Fix:** Either hard-fail at startup if Firebase can't init, or add a dependency-check decorator to every endpoint.

### H-5. Firebase Storage Bucket Not Configured at Init

- **File:** `astra_backend/main.py:81` → `firebase_admin.initialize_app(cred)` — no `storageBucket` option.
- **File:** `astra_backend/main.py:301, 357` → `storage.bucket()` — uses default bucket which may be `None`.
- **Impact:** `storage.bucket()` raises `ValueError` if no default bucket was set and no bucket name is passed.
- **Fix:** `firebase_admin.initialize_app(cred, {'storageBucket': os.getenv('FIREBASE_STORAGE_BUCKET')})`.

### H-6. CORS Wildcard + Credentials = Invalid Per Spec

- **File:** `astra_backend/main.py:204-205` → `allow_origins=["*"], allow_credentials=True`
- **Problem:** Per the CORS specification, `Access-Control-Allow-Origin: *` cannot be used with `Access-Control-Allow-Credentials: true`. Browsers will block credentialed requests.
- **Fix:** Use explicit origin list or drop `allow_credentials=True`.

### H-7. Upload Size Mismatch — UI Says 50GB, Backend Enforces 100MB

- **Frontend:** `lib/features/vault/widgets/upload_modal.dart:243` → label text `"MAX FILE SIZE: 50GB"`
- **Backend:** `astra_backend/main.py:245` → `MAX_SIZE = 100 * 1024 * 1024` (100MB)
- **Impact:** Users attempt large uploads that always get rejected with a confusing error.
- **Fix:** Align both sides to the same limit and display the real value.

### H-8. `DropdownButtonFormField` Uses Non-Existent `initialValue` Parameter

- **File:** `lib/features/auth/login_screen.dart:1405` → `initialValue: dropdownValue,`
- **File:** `lib/features/vault/widgets/upload_modal.dart:331` → `initialValue: _selectedDistribution,`
- **Problem:** `DropdownButtonFormField` does not have an `initialValue` parameter. The correct parameter is `value`.
- **Impact:** Compilation error or runtime assertion failure depending on Flutter version.
- **Fix:** Change `initialValue:` to `value:` in both locations.

### H-9. File Handle Leak in `process_asset` Endpoint

- **File:** `astra_backend/main.py:271`
- **Code:** `await asyncio.to_thread(shutil.copyfileobj, video_file.file, open(temp_video_path, "wb"))`
- **Problem:** `open(temp_video_path, "wb")` creates a file handle that is never explicitly closed. It's passed directly as an argument — no `with` context manager wraps it.
- **Impact:** File descriptor leak under load. On Linux, this hits the ulimit and causes `OSError: [Errno 24] Too many open files`.
- **Fix:** Use `with open(temp_video_path, "wb") as out_f: shutil.copyfileobj(video_file.file, out_f)` in a proper wrapper.

---

## MEDIUM ISSUES

### M-1. `_showProgress` Is `final` and Always `false` — Progress View Never Shows

- **File:** `lib/features/vault/widgets/upload_modal.dart:22` → `final bool _showProgress = false;`
- **Problem:** Declared as `final`, so it can never be set to `true`. The progress view (`_buildProgressView()`) is dead code — it's never rendered.
- **Impact:** Upload modal always shows the form view; the 5-step progress UI is completely unreachable.
- **Fix:** Make it a non-final mutable field and set it in `_startUpload()`.

### M-2. `_currentStep` Is `final` and Always `0` — Step Tracking Broken

- **File:** `lib/features/vault/widgets/upload_modal.dart:38` → `final int _currentStep = 0;`
- **Problem:** Same as M-1. Declared `final`, so `_buildProgressView()` always shows step 0 even if it were ever rendered.
- **Fix:** Make mutable and update during upload lifecycle.

### M-3. Threats Screen Unconditionally Merges Mock Data with Live Data

- **File:** `lib/features/threats/threats_screen.dart:102` → `_alerts = [...liveAlerts, ...ThreatsMockData.alerts];`
- **Problem:** Mock alerts are always appended regardless of `kDemoMode`. Live Firestore alerts and hardcoded fake alerts appear side-by-side.
- **Impact:** Operators cannot distinguish real threats from synthetic ones during triage.
- **Fix:** Gate with `if (kDemoMode) { ... }` or remove mock data entirely for production.

### M-4. Vault Screen Merges Mock Assets When `kDemoMode = true` (Default)

- **File:** `lib/core/config/demo_config.dart:4` → `const bool kDemoMode = true;`
- **File:** `lib/features/vault/vault_screen.dart:49` → `final mockAssets = kDemoMode ? VaultMockData.assets : <VaultedAsset>[];`
- **File:** `lib/features/vault/vault_screen.dart:126` → `final allAssets = <VaultedAsset>[...liveAssets, ...mockAssets];`
- **Impact:** Hardcoded demo stats ("247 ASSETS VAULTED", "2.4 TB STORAGE USED" at lines 184-194) persist alongside real data.
- **Fix:** Default `kDemoMode` to `false` for integration/production builds.

### M-5. Contagion Screen `firstWhere` Without `orElse` — Potential Crash

- **File:** `lib/features/contagion/contagion_screen.dart:70` → `activeNodes.firstWhere((n) => n.id == _selectedNodeId)`
- **File:** `lib/features/contagion/contagion_screen.dart:74` → `activeNodes.firstWhere((n) => n.id == selectedNode!.parentId)`
- **Problem:** `firstWhere` without an `orElse` throws `StateError` if no element matches. If `_selectedNodeId` gets out of sync with mock data (e.g., after switching to live data), this crashes.
- **Fix:** Add `orElse: () => null` pattern using `firstWhereOrNull` from `package:collection`, or add `orElse` fallback.

### M-6. Backend Scanner Calls Synchronous `process_scraped_video` from Async Loop

- **File:** `astra_backend/main.py:157` → `process_scraped_video(video_path, metadata)`
- **Problem:** `process_scraped_video()` in `scanner_pipeline.py` is a synchronous function that calls `extract_frames`, `generate_video_vector`, and Firestore writes. It's called from `run_scanner_cycle()` which is `async` but invokes this function synchronously — blocking the entire asyncio event loop for the duration of AI inference.
- **Impact:** While a scan is running (potentially 30+ seconds for CLIP inference), no other HTTP requests can be served. The API is completely unresponsive.
- **Fix:** Wrap the call in `await asyncio.to_thread(process_scraped_video, video_path, metadata)`.

### M-7. Backend `audio_similarity` Is Faked with `random.uniform()`

- **File:** `astra_backend/scanner_pipeline.py:75` → `audio_similarity = random.uniform(0.80, 0.93)`
- **Problem:** The "DUAL-LOCK" audio matching (prominently featured in the UI at `threat_detail_panel.dart:167`) is completely fake — just a random number. The frontend presents this as a real forensic metric.
- **Impact:** Misleading forensic evidence. The "audio waveform match" confidence circle is meaningless data.
- **Fix:** Either implement real audio fingerprinting or clearly label it as "SIMULATED" in the UI.

### M-8. `media_processor.py` Creates Global `FRAMES_TEMP_DIR` But Never Uses It

- **File:** `astra_backend/media_processor.py:10-13` → `FRAMES_TEMP_DIR = "astra_backend/temp/frames"` + `os.makedirs(FRAMES_TEMP_DIR, exist_ok=True)`
- **Problem:** This directory is created on module import but `extract_frames()` takes `output_directory` as a parameter and never references `FRAMES_TEMP_DIR`.
- **Impact:** Dead code that creates unnecessary filesystem artifacts on import.
- **Fix:** Remove the unused constant and `os.makedirs` call.

### M-9. Dual `onPressed` / `onTap` Conflict on ScaleButton-Wrapped Buttons

- **Files:**
  - `lib/features/threats/widgets/threat_detail_panel.dart:134` → `OutlinedButton(onPressed: () {})` wrapped in `ScaleButton(onTap: () {})`
  - `lib/features/threats/widgets/threat_detail_panel.dart:753` → `ElevatedButton(onPressed: () {})` wrapped in `ScaleButton(onTap: _reveal)`
  - `lib/features/threats/widgets/threat_detail_panel.dart:794` → `OutlinedButton(onPressed: () {})` wrapped in `ScaleButton(onTap: _reveal)`
  - `lib/features/vault/vault_screen.dart:157` → `ElevatedButton(onPressed: () {})` wrapped in `ScaleButton(onTap: _showUploadModal)`
- **Problem:** `ScaleButton` handles the tap via `onTap`, but the inner `ElevatedButton`/`OutlinedButton` has a separate `onPressed: () {}` (no-op). This creates ambiguous tap targets — the `ElevatedButton` may absorb the gesture before `ScaleButton` sees it, depending on the hit-test order.
- **Impact:** Buttons may appear to do nothing on tap if the inner button's gesture detector wins.
- **Fix:** Set `onPressed: null` on inner buttons (to disable their gesture) or remove `ScaleButton` wrapper and put the logic directly on `onPressed`.

### M-10. Analyzer Suppresses Missing Asset Warnings

- **File:** `analysis_options.yaml:14` → `asset_does_not_exist: ignore`
- **Impact:** Missing or misconfigured asset paths (images, fonts, config files) are silently ignored at compile time, only failing at runtime.
- **Fix:** Remove the ignore rule. Fix any asset-not-found warnings it surfaces.

### M-11. Backend `.env` Loading Uses Wrong Relative Path

- **File:** `astra_backend/main.py:35` → `load_dotenv()`
- **Problem:** `load_dotenv()` without arguments reads `.env` from the **current working directory**. If you run `uvicorn astra_backend.main:app` from the project root, it reads `/.env` (root-level), not `astra_backend/.env` or `astra_backend/config/.env`.
- **File:** `astra_backend/main.py:74` → `firebase_creds_path = os.getenv("FIREBASE_CREDENTIALS_PATH")` which is set to `./serviceAccountKey.json` in the config `.env` — a path relative to CWD, not to the backend folder.
- **Impact:** Environment variables are never loaded if server is started from the project root. Firebase credentials path resolves to wrong location.
- **Fix:** Use `load_dotenv(dotenv_path=os.path.join(os.path.dirname(__file__), '.env'))` or use absolute paths.

### M-12. Contagion Graph Painter Positions 12 Nodes at Same X-Coordinate

- **File:** `lib/features/contagion/widgets/contagion_graph_painter.dart:48-49`
- **Code:** `for (int i = 6; i <= 17; i++) { nodePositions["N$i"] = Offset(step4X, h * (0.08 + (i - 6) * 0.08)); }`
- **Problem:** Nodes N6-N17 (12 nodes) are plotted at the same X position with Y spacing of `0.08 * h`. At 800px height, that's 64px per node. But the mock data only has nodes N6-N9 as T2 and N10-N17 as T3 — the painter treats all 12 as "endpoints" regardless of tier. Also, nodes N4 and N5 are positioned as "HUB" but the actual mock data has 6 T2 nodes (N4-N9), not 2.
- **Impact:** The graph layout does not match the actual data topology. T2 nodes N6-N9 are mispositioned and T3 nodes overlap with T2 in the same column.
- **Fix:** Derive positions from the actual node tier/count rather than hardcoding indices.

### M-13. `contagion_graph_painter.dart` Treats `T2` as "endpoint" but `T3` Exists

- **File:** `lib/features/contagion/widgets/contagion_graph_painter.dart:132` → `final bool isEndpoint = node.tier == "T2";`
- **Problem:** T3 is the actual leaf/endpoint tier in the data model, but the painter considers T2 as the endpoint. T3 nodes get the non-endpoint (larger) rendering style.
- **Fix:** Change to `node.tier == "T3"` or derive from child count.

---

## LOW ISSUES

### L-1. `_assetName` Field in Upload Modal Is Set But Never Sent to Backend

- **File:** `lib/features/vault/widgets/upload_modal.dart:24` → `String _assetName = "";`
- **File:** Line 268 → `onChanged: (v) => _assetName = v,` — user types asset name.
- **File:** Line 74-77 → `FormData.fromMap({'distribution_target': ..., 'video_file': ...})` — `_assetName` is never included.
- **Impact:** User-entered asset name is discarded. Backend uses `video_file.filename` instead.

### L-2. Rate Limiter Uses In-Memory Dict — Resets on Every Restart

- **File:** `astra_backend/main.py:38` → `request_history = {}`
- **Problem:** Rate limiting state is stored in a Python dict. Server restart clears all history. Not effective for distributed/multi-worker deployments.
- **Impact:** Rate limiting is trivially bypassed by restarting the server or using multiple workers.

### L-3. `Dio` Client Imports `dart:io` — Breaks on Web

- **File:** `lib/core/services/dio_client.dart:2` → `import 'dart:io';`
- **Problem:** `dart:io` is not available on web platform. The import is used for `SocketException` check at line 13.
- **Impact:** Compilation failure when targeting Flutter Web (the primary target for this project).
- **Fix:** Use conditional imports or remove the `SocketException` check for web builds.

### L-4. `graphview` Package Imported But Unused in Contagion Screen

- **File:** `lib/features/contagion/contagion_screen.dart:10` → `import 'package:graphview/graphview.dart' as gv;`
- **Problem:** The `gv` alias is never referenced anywhere in the file. The contagion graph uses a custom `PropagationFlowPainter` instead.
- **Impact:** Unnecessary dependency bloat.

### L-5. Contagion Nodes Written to Firestore with Fake Hardcoded URLs

- **File:** `astra_backend/scanner_pipeline.py:111` → `"url": "https://youtube.com/fake_mirror"`
- **Problem:** When a real threat is detected, the contagion nodes written to Firestore contain fake placeholder URLs and platform names.
- **Impact:** Live forensic graph shows fake propagation data alongside real detection data.

### L-6. `generationConfig` Sends Duplicate Keys to Gemini API

- **File:** `astra_backend/threat_detector.py:114-115`
- **Code:** `"responseMimeType": "application/json", "response_mime_type": "application/json"`
- **Problem:** Sends both camelCase and snake_case versions of the same config key. The Gemini API uses `responseMimeType` (camelCase). The snake_case duplicate is ignored but adds confusion.

### L-7. Backend `load_dotenv()` Called Before Imports That Need Env Vars

- **File:** `astra_backend/main.py:35` — `load_dotenv()` is called after importing `scanner_pipeline`, `media_processor`, `vectorizer`, and `watermark` at lines 26-29.
- **Problem:** `vectorizer.py` runs model loading at import time (line 17-19) which doesn't depend on env vars, but `scanner_pipeline.py` imports `threat_detector.py` which reads `GEMINI_API_KEY` at runtime — this is fine. However, the import order creates a fragile dependency chain.

### L-8. Dashboard Stats Are Entirely Hardcoded

- **File:** `lib/features/vault/vault_screen.dart:184-194` → `"247"`, `"2.4 TB"`, `"100%"`
- **Impact:** These values never reflect real data. They are static text, not connected to Firestore or any data source.

### L-9. Redundant Re-imports Inside Function Bodies

- **File:** `astra_backend/main.py:344` → `from fastapi.responses import JSONResponse` (already imported at line 54)
- **File:** `astra_backend/main.py:366` → `import ffmpeg` (already imported at line 53)
- **File:** `astra_backend/main.py:376` → `from stegano import lsb` (already imported at line 56)
- **File:** `astra_backend/main.py:381-383` → re-imports `base64`, `json`, `Fernet` (all already imported at top)
- **File:** `astra_backend/main.py:398` → `from fastapi.responses import JSONResponse` again
- **File:** `astra_backend/main.py:402` → `import shutil` (already imported at line 21)
- **Impact:** Code clutter, no runtime effect.

### L-10. `_selectedFile` Picked Twice in Upload Modal

- **File:** `lib/features/vault/widgets/upload_modal.dart:48-51` — `_startUpload()` calls `FilePicker.platform.pickFiles()`.
- **File:** `lib/features/vault/widgets/upload_modal.dart:191` — The drag-drop zone's `onTap` also calls `FilePicker.platform.pickFiles()`.
- **Problem:** User can pick a file via the drop zone, then `_startUpload()` opens the file picker *again*, discarding the previously selected file.
- **Fix:** `_startUpload()` should use `_selectedFile` if already set, not re-pick.

---

## Backend ↔ Frontend Integration Summary

| Flow | Frontend Path | Backend Path | Status |
|------|-------------|-------------|--------|
| Upload Asset | `POST /process-asset` | `POST /processasset` | **BROKEN** (404) |
| Decrypt Watermark | `POST /decrypt-watermark` | `POST /decrypt-watermark` | Matching (works if backend reachable) |
| Health Check | Not called from frontend | `GET /` | Available but unused |
| Vault Data | Firestore `vaulted_assets` stream | Writes to `vaulted_assets` | **Works** (via Firestore, not HTTP) |
| Threat Data | Firestore `threat_alerts` stream | Writes to `threat_alerts` | **Works** (via Firestore, not HTTP) |
| Contagion Data | Firestore `contagion_nodes` stream | Writes to `contagion_nodes` | **Works** (via Firestore, not HTTP) |
| Dashboard KPIs | Hardcoded / mock data | N/A | **No backend integration** |

---

## Suggested Fix Order

| Priority | Bug ID | Action |
|----------|--------|--------|
| 1 | C-1, C-2 | Rotate Firebase service account key; sanitize `.env` template |
| 2 | C-4, C-5 | Fix `urlPathStrategy` and `AnimatedBuilder`/`DropdownButtonFormField` compile errors |
| 3 | C-3 | Stop bundling backend `.env` as Flutter asset |
| 4 | C-5 | Align `/process-asset` route between frontend and backend |
| 5 | H-1 | Add uvicorn entrypoint or fix README run instructions |
| 6 | H-2 | Replace placeholder API URL with env-driven config |
| 7 | H-3 | Fix watermark temp file race condition |
| 8 | H-4, H-5 | Hard-fail on missing Firebase init; configure storage bucket |
| 9 | H-6 | Fix CORS wildcard + credentials conflict |
| 10 | H-7, H-8 | Fix upload size label; fix `initialValue` → `value` |
| 11 | M-1, M-2 | Make `_showProgress`/`_currentStep` mutable |
| 12 | M-3, M-4 | Gate mock data behind `kDemoMode` properly; default it to `false` |
| 13 | M-6 | Wrap blocking scanner call in `asyncio.to_thread()` |
| 14 | L-3 | Fix `dart:io` import for web compatibility |

---

## Notes

- This report is based on exhaustive static code analysis across all source files.
- No source code was modified during this audit.
- Line numbers reference the file state as of 2026-04-24.
