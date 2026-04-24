# ASTRA Project Bug Report (Backend + Full Project)

Date: 2026-04-24
Repository: Digital-Asset-Protection

## Scope Covered

- Backend: FastAPI pipeline, watermarking, scanner, threat detection, config/security
- Frontend: Flutter routing, API integration, vault/threats/contagion/dashboard flows, environment setup
- Cross-cutting: Backend-frontend integration and runtime readiness

## Severity Legend

- Critical: Breaks core functionality, exposes sensitive data, or blocks deploy
- High: Major reliability/security/integration issue
- Medium: Incorrect behavior, UX mismatch, or technical debt with user impact
- Low: Minor issues or polish gaps

---

## Critical Issues

1. Leaked Firebase service account private key in repository
- Evidence: astra_backend/config/serviceAccountKey.json:5 contains full private key material.
- Evidence: astra_backend/config/serviceAccountKey.json:4 has private key id and complete service account object is present.
- Impact: Full backend compromise risk (Firestore/Storage/admin actions), credential abuse, potential data breach.
- Fix: Immediately revoke and rotate this service account key in Firebase/GCP; remove file from git history; keep only secure secret management.

2. Backend start command in README does not actually run FastAPI server
- Evidence: README.md:151 instructs running `python astra_backend/main.py`.
- Evidence: astra_backend/main.py has no `uvicorn.run(...)` and no `if __name__ == "__main__":` entrypoint.
- Impact: Following docs starts scanner logic only if imported in ASGI flow; API server is not started by this command, frontend cannot call backend APIs.
- Fix: Update run instructions to `uvicorn astra_backend.main:app --reload --host 0.0.0.0 --port 8000` or add proper main entrypoint.

3. Frontend upload endpoint path does not match backend route
- Evidence: Backend route is `@app.post("/processasset")` at astra_backend/main.py:228.
- Evidence: Frontend calls `${ApiConfig.backendBaseUrl}/process-asset` at lib/features/vault/widgets/upload_modal.dart:80.
- Impact: Upload always fails with 404; asset vaulting pipeline is effectively disconnected.
- Fix: Standardize route naming on both sides (either `/processasset` or `/process-asset`) and update tests/docs.

4. Flutter app has compile error in router configuration
- Evidence from analyzer: lib/core/navigation/app_router.dart:51 uses unknown named parameter `urlPathStrategy` and undefined `UrlPathStrategy`.
- Impact: Build/analyze fails; app cannot compile cleanly.
- Fix: Remove/replace invalid parameter per installed go_router version.

---

## High Issues

1. API base URL is placeholder, not a usable backend address
- Evidence: lib/core/config/api_config.dart:5 uses `https://<YOUR-NGROK-ID>.ngrok-free.app`.
- Impact: All direct backend API calls fail unless manually edited each run.
- Fix: Use environment-driven config and fail-fast validation if placeholder remains.

2. Frontend UI says max upload size 50GB, backend enforces 100MB
- Evidence: UI label `MAX FILE SIZE: 50GB` at lib/features/vault/widgets/upload_modal.dart:243.
- Evidence: Backend max size `100 * 1024 * 1024` at astra_backend/main.py:245 and error message at line 250.
- Impact: Severe UX mismatch; users attempt uploads that backend always rejects.
- Fix: Align constraints and communicate actual limit from backend/config.

3. Watermarking temp files are global/static, unsafe for concurrent requests
- Evidence: astra_backend/watermark.py:41-43 uses fixed paths `temp/frame_to_mark.png`, `temp/frame_marked.png`, `temp/watermarked_video.mp4`.
- Impact: Concurrent uploads can overwrite each other, produce corrupted output, or wrong watermark attribution.
- Fix: Use per-request temp directory and unique filenames.

4. Firebase backend initialization is optional, but endpoints assume it is initialized
- Evidence: main logs warning when creds missing (astra_backend/main.py around line 83), but endpoints still call firestore/storage directly at lines 262, 301, 340, 357.
- Impact: Runtime failures on first API call when Firebase init fails.
- Fix: Hard-fail startup if required services are missing, or gate endpoints with explicit health/availability checks.

5. Firebase Storage bucket likely unconfigured in backend init
- Evidence: firebase init call `firebase_admin.initialize_app(cred)` at astra_backend/main.py:81 with no storage bucket options.
- Evidence: code later uses `storage.bucket()` at lines 301 and 357.
- Impact: Upload/download may fail with default bucket not set depending on environment.
- Fix: Initialize app with storage bucket config (from env) or call `storage.bucket(bucket_name)` explicitly.

6. Insecure CORS configuration for credentialed requests
- Evidence: astra_backend/main.py:204 sets `allow_origins=["*"]` with `allow_credentials=True` at line 205.
- Impact: Browser CORS behavior is invalid for credentialed wildcard origins; security and interoperability risk.
- Fix: Use explicit trusted origins; only enable credentials when required.

7. Secret/config handling pattern leaks backend env into frontend bundle
- Evidence: pubspec.yaml:56 includes asset `astra_backend/config/.env`.
- Evidence: lib/main.dart:16 loads that file via flutter_dotenv.
- Impact: Any secrets placed in this file can be shipped to client builds.
- Fix: Separate frontend public config and backend private secrets; never bundle server secrets into Flutter assets.

---

## Medium Issues

1. Backend file copy opens file handle inline without clear close lifecycle
- Evidence: astra_backend/main.py:271 calls `open(temp_video_path, "wb")` inside `shutil.copyfileobj` thread call.
- Impact: Potential file descriptor/resource leak under load.
- Fix: Use `with open(...) as out_f:` pattern.

2. Threats screen mixes live Firestore data with mock alerts unconditionally
- Evidence: lib/features/threats/threats_screen.dart:102 merges live alerts with `ThreatsMockData.alerts`.
- Impact: Operators see synthetic and real incidents together, distorting triage.
- Fix: Gate mock data by demo flag or remove in production mode.

3. Vault screen mixes live data with mock data while demo mode enabled by default
- Evidence: lib/core/config/demo_config.dart:4 sets `kDemoMode = true`.
- Evidence: lib/features/vault/vault_screen.dart:49 appends `VaultMockData.assets`.
- Impact: False inventory counts and misleading operational state.
- Fix: Default demo mode off for integration testing and production.

4. Contagion flow defaults to mock graph unless specific threat id has live nodes
- Evidence: lib/features/contagion/contagion_screen.dart:68 uses `ContagionMockData.nodes` baseline.
- Impact: Can misrepresent forensic graph as live when data is synthetic.
- Fix: Clear UI state labels and enforce explicit source mode.

5. Analyzer hides missing asset issues
- Evidence: analysis_options.yaml:14 sets `asset_does_not_exist: ignore`.
- Impact: Missing asset/config problems are masked until runtime.
- Fix: Remove ignore for CI/build quality.

6. Frontend contains multiple non-functional action buttons
- Evidence examples:
  - lib/features/threats/threats_screen.dart:159 (`onPressed: () {}`)
  - lib/features/threats/widgets/threat_detail_panel.dart:134 (`onPressed: () {}`)
  - lib/features/vault/widgets/upload_modal.dart:516 and 537
- Impact: UI suggests actions that do nothing, reducing operator trust.
- Fix: Wire handlers or disable/hide until implemented.

---

## Backend ↔ Frontend Connection Gaps (Explicit)

1. Direct API mismatch in upload flow
- Frontend expects: `POST /process-asset`
- Backend exposes: `POST /processasset`
- Result: Upload path is disconnected.

2. Backend base URL configuration is not production/integration safe
- Placeholder URL in frontend config prevents real API communication unless manually edited.

3. Most frontend modules do not call backend APIs directly
- Vault upload and watermark decrypt are the only direct backend HTTP flows found.
- Dashboard, Threats list, Contagion, and KPIs mostly consume Firestore and/or mock data.
- This means backend-FastAPI and frontend are loosely coupled through Firestore, not fully integrated end-to-end APIs.

4. Demo mode defaults and mock blending hide real integration status
- Because `kDemoMode` is true and mock data is merged, it is difficult to verify whether backend outputs are truly driving UI behavior.

5. Backend startup docs do not launch API server
- Even with frontend configured, API is unreachable if README command is followed.

---

## Suggested Fix Order (Practical)

1. Rotate/revoke leaked service account key and purge secret from repository history.
2. Fix backend run command and ensure API server starts consistently.
3. Align upload route naming (`/processasset` vs `/process-asset`).
4. Fix router compile error (`urlPathStrategy`) so app builds cleanly.
5. Replace placeholder backend URL with env-based config strategy.
6. Remove mock-data blending for production/integration mode.
7. Fix watermark temp-file concurrency and backend resource handling.
8. Harden CORS and Firebase initialization checks.
9. Align upload size limits between UI and backend.
10. Re-enable analyzer checks for missing assets in CI.

---

## Notes

- This report is based on static code analysis plus analyzer diagnostics available in the workspace.
- No destructive changes were made to source code during this analysis.
