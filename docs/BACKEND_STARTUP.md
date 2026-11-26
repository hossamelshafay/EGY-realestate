# Local backend startup

After restarting Windows, double-click **START_BACKEND.bat** in the project root.
No activation, terminal profile, Codex, or app reinstall is needed. Keep the window
open. Startup can take several minutes while models and Gemini initialize.
The launcher uses the existing backend .venv (or venv), its base Python installation,
the existing .env and Firebase Admin credentials. It runs one Uvicorn worker bound
to 0.0.0.0:8000; models run inside FastAPI, with recommendations loaded on demand.

Press **Ctrl+C** in the original server window and wait for shutdown to stop safely.
A second launch reports an already healthy EGY server and does not own or stop it.
Error and reuse windows pause so you can read their messages.

Check http://127.0.0.1:8000/api/health in a browser. Full readiness requires HTTP 200,
model_loaded=true, llm_client_ready=true, llm_backend=GeminiClient. HTTP 200 alone
can also mean degraded service. Recommendations require an authenticated request
to verify their lazy-loaded artifacts. Prediction, recommendations and chat require
a Firebase login; an unauthenticated 401 is expected and is not a startup failure.

## Android

For USB, enable USB debugging, connect the phone, and accept its authorization
prompt. Launch again after connecting if necessary. The launcher finds adb on PATH
or in ANDROID_HOME, ANDROID_SDK_ROOT or the usual local Android SDK folder, runs
reverse for each authorized device and verifies the mapping. No phone is required
to start the backend. USB reverse is lost on disconnect/reboot; launching restores it.

For USB reverse the app must have been built with
`--dart-define=API_BASE_URL=http://127.0.0.1:8000`.
This loopback address works on a physical phone **only with ADB reverse**.
For Wi-Fi use the current Wi-Fi URL printed by the launcher, with both devices on
the same trusted LAN. For the Android emulator use http://10.0.2.2:8000.
If the address changes, build/run with the matching API_BASE_URL yourself;
the launcher never rebuilds or installs Flutter. A router DHCP reservation can
keep the Wi-Fi address stable. Windows Firewall is never changed automatically.

## Troubleshooting and setup

- **Port 8000 occupied:** healthy EGY is reused. For any other listener, the launcher
  stops with an error. Inspect `Get-NetTCPConnection -LocalPort 8000` and its
  OwningProcess in Task Manager. Stop only an application you recognize, or stop
  the original EGY window with Ctrl+C. The launcher never kills unrelated processes.
- **Another launcher starting:** wait for its READY message. Windows releases the
  launcher lock automatically after a crash; never delete environments or models.
- **Missing venv/base Python:** restore/install Python 3.13 matching
  EGY_DEVELOPMENT_ai/.venv/pyvenv.cfg. A venv depends on that base installation.
  If no venv exists, from the backend directory run `py -3.13 -m venv .venv`, then
  `.venv\Scripts\python.exe -m pip install -r requirements.txt`.
  Do not overwrite a working environment. The saved price artifact requires
  scikit-learn 1.9.1; if pip cannot resolve it, restore the known working environment
  or obtain compatible dependencies/artifacts from the maintainer, never retrain automatically.
- **Missing dependencies:** from the backend directory run
  `.venv\Scripts\python.exe -m pip install -r requirements.txt` (use venv if applicable).
- **Configuration:** keep the existing backend .env, GEMINI_API_KEY and GEMINI_MODEL.
  Firebase uses GOOGLE_APPLICATION_CREDENTIALS if set, otherwise
  `%USERPROFILE%\firebase-secrets\egy-firebase-admin.json`. Do not move or publish
  this private file. Clear FIREBASE_AUTH_EMULATOR_HOST for real Firebase.
- **Missing artifact:** restore the exact named file from your project backup.
  No model, dataset, cache or environment is automatically deleted or downloaded.
- **Gemini not ready:** check connectivity, key validity, model access and quota.
  Startup verifies Gemini availability and may contact its model API. It does not
  send a chatbot prompt. Use the signed-in app to test a real response.
- **Phone cannot connect:** check matching API_BASE_URL, USB authorization/reverse,
  network isolation and your Windows Firewall permissions manually.

Sanitized backend output and readiness diagnostics are appended to the ignored
`backend_startup.log` in the project root. Prerequisite failures appear in the
paused window before the server starts. Never share .env or credential files.
Advanced checks: `powershell -NoProfile -ExecutionPolicy Bypass -File
scripts/start_local_backend.ps1 -CheckOnly`. `-DisableChat` is an explicit diagnostic
mode; normal double-click startup enables Gemini and requires full readiness.

## Investigation evidence (2026-11-25)

The old script was reproduced failing because port 8000 was already occupied.
Its listener (PID 17756 during inspection) returned HTTP 200 with status=ok,
model_loaded=true and llm_client_ready=true, GeminiClient. Preflight passed under
the owner account. Thus the observed failure was duplicate startup rejection,
not a broken model or venv. This does not establish the historical state immediately
after reboot. The isolated Codex sandbox separately could not access the user's
base Python; owner-account testing was required to distinguish that limitation.

Verification: clean NoProfile startup loaded the actual price model and confirmed
Gemini model availability (provider HTTP 200), then /api/health returned HTTP 200
with both readiness flags true. Batch launches twice from C:\Windows\Temp reused
the original PID; another launch reused the newly supervised server. USB ADB reverse
was verified on the connected phone. An intentional emulator configuration error
returned failure and reached the batch pause with an actionable message.
Existing offline integration suites passed 9 + 3 tests, including real price,
catalog, recommendation search/similar and a scripted chatbot tool loop. HTTP tests
use test-only Firebase overrides; no production authentication was bypassed.
No live authenticated phone request or paid Gemini generation was tested. Unrelated
port conflicts and interrupted startup cleanup are implemented but not fault-injected.
