[CmdletBinding()]
param(
    [switch] $DisableChat,
    [switch] $CheckOnly
)

$ErrorActionPreference = 'Stop'
$backend = Join-Path (Split-Path -Parent $PSScriptRoot) 'EGY_DEVELOPMENT_ai'
$python = Join-Path $backend '.venv\Scripts\python.exe'
$firebase = Join-Path $env:USERPROFILE 'firebase-secrets\egy-firebase-admin.json'
$port = 8000

$requiredFiles = @(
    $python
    $firebase
    (Join-Path $backend '.env')
    (Join-Path $backend 'app.py')
    (Join-Path $backend 'models\regression\final_price_prediction_model.joblib')
    (Join-Path $backend 'data\processed\recommendations\cleaned_properties.parquet')
    (Join-Path $backend 'models\recommendation\id_to_idx.joblib')
    (Join-Path $backend 'models\recommendation\idx_to_id.joblib')
    (Join-Path $backend 'models\recommendation\top_indices.npy')
    (Join-Path $backend 'models\recommendation\top_scores.npy')
    (Join-Path $backend 'models\recommendation\feature_matrix.npz')
)
if (-not $DisableChat) {
    $requiredFiles += @(
        (Join-Path $backend 'data\processed\chat_bot\chatbot_properties_v2.parquet')
        (Join-Path $backend 'data\processed\chat_bot\amenities_mapping_v2.json')
        (Join-Path $backend 'data\processed\chat_bot\location_lookup.csv')
    )
}
foreach ($file in $requiredFiles) {
    if (-not (Test-Path -LiteralPath $file -PathType Leaf)) {
        throw "Required file missing: $file"
    }
}
if ($env:FIREBASE_AUTH_EMULATOR_HOST) {
    throw 'Clear FIREBASE_AUTH_EMULATOR_HOST in this terminal. This backend expects real Firebase Auth.'
}

$portInUse = [Net.NetworkInformation.IPGlobalProperties]::GetIPGlobalProperties().
    GetActiveTcpListeners().Port -contains $port
$healthUrl = "http://127.0.0.1:$port/api/health"
if ($portInUse -and -not $CheckOnly) {
    throw "TCP port $port is already in use. Check $healthUrl or stop the existing listener before starting."
}

$wifiUrls = @(
    foreach ($adapter in [Net.NetworkInformation.NetworkInterface]::GetAllNetworkInterfaces()) {
        if ($adapter.OperationalStatus -ne 'Up' -or $adapter.NetworkInterfaceType -ne 'Wireless80211') {
            continue
        }
        foreach ($entry in $adapter.GetIPProperties().UnicastAddresses) {
            $address = $entry.Address
            if ($address.AddressFamily -eq 'InterNetwork' -and $address.IPAddressToString -notlike '169.254.*') {
                "http://${address}:$port ($($adapter.Name))"
            }
        }
    }
)
if ($wifiUrls.Count) {
    $wifiUrls | ForEach-Object { Write-Host "Wi-Fi API URL: $_" }
} else {
    Write-Warning 'No active Wi-Fi IPv4 address found. Check ipconfig for the adapter on the phone network.'
}
Write-Host "Local health: $healthUrl"

$processSettings = @{
    GOOGLE_APPLICATION_CREDENTIALS = $firebase
    CHAT_ENABLED = $(if ($DisableChat) { 'false' } else { 'true' })
    LLM_PROVIDER = 'gemini'
}
$previous = @{}
Push-Location -LiteralPath $backend
try {
    foreach ($name in $processSettings.Keys) {
        $previous[$name] = [Environment]::GetEnvironmentVariable($name, 'Process')
        [Environment]::SetEnvironmentVariable($name, $processSettings[$name], 'Process')
    }
    $preflight = @'
import sys
try:
    import uvicorn
    import sklearn
    from core.config import settings
    from core.auth import _admin_app

    if sklearn.__version__ != "1.9.1":
        sys.exit("This saved price model requires scikit-learn 1.9.1 in the backend .venv.")
    if settings.chat_enabled:
        import google.genai
        if not settings.gemini_api_key.strip():
            sys.exit("Gemini is enabled. Set GEMINI_API_KEY in the backend .env file.")
    admin = _admin_app()
    if admin.credential.get_credential().project_id != admin.project_id:
        sys.exit("Firebase service-account project does not match the FastAPI Firebase project.")
    print(f"Python {sys.version.split()[0]} | Firebase Admin: {admin.project_id} | Chat enabled: {settings.chat_enabled}")
except Exception as error:
    sys.exit(f"Backend preflight failed ({type(error).__name__}). Check .venv, .env, and the Firebase service-account file.")
'@
    $preflight | & $python -B -
    if ($LASTEXITCODE -ne 0) { throw 'Backend prerequisites did not pass.' }
    if ($CheckOnly) {
        if ($portInUse) { Write-Host "TCP port $port already has a listener. No server was started." }
        return
    }
    Write-Host "Starting FastAPI on 0.0.0.0:$port. Press Ctrl+C to stop."
    & $python -B -m uvicorn app:app --host 0.0.0.0 --port $port
    if ($LASTEXITCODE -ne 0) { throw "Uvicorn exited with code $LASTEXITCODE." }
} finally {
    foreach ($name in $previous.Keys) {
        [Environment]::SetEnvironmentVariable($name, $previous[$name], 'Process')
    }
    Pop-Location
}
