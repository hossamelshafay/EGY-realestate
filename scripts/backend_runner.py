"""Windows local launcher supervisor; leaves backend source/config untouched."""
import json
import os
from pathlib import Path
import re
import shutil
import socket
import subprocess
import sys
import threading
import time
from urllib.request import urlopen

ROOT = Path(__file__).resolve().parents[1]
BACKEND = ROOT / 'EGY_DEVELOPMENT_ai'
LOG = ROOT / 'backend_startup.log'
BASE = 'http://127.0.0.1:8000'
sys.path.insert(0, str(BACKEND))


def main():
    # Existing settings loader parses .env; never echo its contents or validation values.
    from dotenv import dotenv_values
    values = {**dotenv_values(BACKEND / '.env'), **os.environ}
    secrets = [str(v) for k, v in values.items() if v and
               any(s in k.upper() for s in ('KEY', 'TOKEN', 'SECRET', 'PASSWORD'))]

    def report(message):
        message = str(message)
        for secret in secrets:
            message = message.replace(secret, '[REDACTED]')
        message = re.sub(r'(?i)(key=|Bearer\s+)[^\s&"\']+', r'\1[REDACTED]', message)
        with LOG.open('a', encoding='utf-8') as stream:
            stream.write(time.strftime('%Y-%m-%d %H:%M:%S ') + message.rstrip() + '\n')
        print(message.rstrip(), flush=True)

    def request(path):
        with urlopen(BASE + path, timeout=2) as response:
            return json.load(response)

    def healthy():
        try:
            schema = request('/openapi.json')
            if schema['info']['title'] != 'Egyptian Real Estate AI Platform':
                return False
            health = request('/api/health')
            return health.get('model_loaded') is True and (
                os.environ.get('CHAT_ENABLED') == 'false' or
                (health.get('llm_client_ready') is True and health.get('llm_backend') == 'GeminiClient'))
        except Exception:
            return False

    def occupied():
        with socket.socket() as sock:
            return sock.connect_ex(('127.0.0.1', 8000)) == 0

    def android():
        adb = shutil.which('adb')
        if not adb:
            for base in (os.environ.get('ANDROID_HOME'), os.environ.get('ANDROID_SDK_ROOT'),
                         str(Path(os.environ.get('LOCALAPPDATA', '')) / 'Android' / 'Sdk')):
                if base and (Path(base) / 'platform-tools' / 'adb.exe').is_file():
                    adb = str(Path(base) / 'platform-tools' / 'adb.exe')
                    break
        if not adb:
            report('ADB unavailable (optional). Use the displayed Wi-Fi URL.')
            return
        try:
            devices = subprocess.run([adb, 'devices'], capture_output=True, text=True, timeout=20)
            ready = [line.split()[0] for line in devices.stdout.splitlines()[1:]
                     if len(line.split()) == 2 and line.split()[1] == 'device']
            if not ready:
                report('No authorized Android device. USB debugging/authorization is optional for backend startup.')
            for serial in ready:
                result = subprocess.run([adb, '-s', serial, 'reverse', 'tcp:8000', 'tcp:8000'],
                                        capture_output=True, text=True, timeout=15)
                check = subprocess.run([adb, '-s', serial, 'reverse', '--list'],
                                       capture_output=True, text=True, timeout=15)
                report('ADB reverse verified: phone API_BASE_URL=http://127.0.0.1:8000'
                       if result.returncode == 0 and 'tcp:8000 tcp:8000' in check.stdout
                       else 'ADB reverse failed. Check USB debugging and reconnect the phone.')
        except (OSError, subprocess.TimeoutExpired):
            report('ADB unavailable or timed out; backend is unaffected.')
        report('App build API_BASE_URL must match USB or Wi-Fi URL. No app rebuild/install performed.')

    # File locking is released by Windows even if startup is interrupted.
    import msvcrt
    with (ROOT / 'backend_startup.lock').open('a+b') as lock:
        lock.seek(0)
        try:
            msvcrt.locking(lock.fileno(), msvcrt.LK_NBLCK, 1)
        except OSError:
            if healthy():
                report('EGY Backend is already healthy: ' + BASE)
                android()
                return 0
            report('Another EGY launcher is starting or serving. Wait and check ' + BASE + '/api/health')
            return 1
        if occupied():
            if healthy():
                report('EGY Backend is already healthy: ' + BASE)
                android()
                return 0
            report('ERROR: Port 8000 is occupied by another application or an unhealthy backend. '
                   'Inspect Get-NetTCPConnection -LocalPort 8000. No process was stopped.')
            return 1
        report('Starting one FastAPI worker. Diagnostics: ' + str(LOG))
        child = subprocess.Popen([sys.executable, '-B', '-m', 'uvicorn', 'app:app',
                                  '--host', '0.0.0.0', '--port', '8000'], cwd=BACKEND,
                                 stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
                                 text=True, encoding='utf-8', errors='replace',
                                 env={**os.environ, 'PYTHONIOENCODING': 'utf-8'})
        def output():
            for line in child.stdout:
                report(line)
        reader = threading.Thread(target=output, daemon=True)
        reader.start()
        try:
            deadline = time.monotonic() + 240
            while child.poll() is None and time.monotonic() < deadline:
                if healthy():
                    report('READY: Price model and Gemini healthy. API: ' + BASE)
                    android()
                    report('Keep this window open. Press Ctrl+C to stop safely.')
                    return child.wait()
                time.sleep(2)
            report('ERROR: Backend exited or failed full readiness within 240 seconds. '
                   'See diagnostics above (model, dependencies, Gemini network/key/quota).')
            return 1
        except KeyboardInterrupt:
            report('Stopping backend...')
            # Console Ctrl+C is also delivered to Uvicorn, allowing lifespan cleanup.
            try:
                child.wait(timeout=15)
            except subprocess.TimeoutExpired:
                child.terminate()
            return 0
        finally:
            if child.poll() is None:
                child.terminate()
                child.wait(timeout=15)
            reader.join(timeout=3)


if __name__ == '__main__':
    try:
        sys.exit(main())
    except Exception as error:
        print('Launcher failed (' + type(error).__name__ + '). Check Python/dependencies, '
              'configuration and log file permissions. See docs/BACKEND_STARTUP.md.', flush=True)
        sys.exit(1)
