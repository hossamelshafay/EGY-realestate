"""Disposable Firebase Auth smoke test. Never changes the phone's signed-in user.

Creates an isolated example.invalid account and deletes that same UID in finally.
Never prints API keys, tokens, passwords, real account details, or response bodies.
"""
import json
from pathlib import Path
import secrets
import re
import sys
import time
from urllib.error import HTTPError
from urllib.request import Request, urlopen


def main():
    root = Path(__file__).resolve().parents[1]
    config = json.loads((root / 'android/app/google-services.json').read_text())
    key = config['client'][0]['api_key'][0]['current_key']
    project = config['project_info']['project_id']
    email = f'egy-ui-smoke-{int(time.time())}-{secrets.token_hex(4)}@example.invalid'
    password = secrets.token_urlsafe(24) + 'aA1!'
    replacement = secrets.token_urlsafe(24) + 'bB2!'
    token = None
    uid = None
    stage = 'create isolated test account'

    def auth(action, body):
        request = Request('https://identitytoolkit.googleapis.com/v1/accounts:' + action + '?key=' + key,
                          data=json.dumps(body).encode(), headers={'Content-Type': 'application/json'})
        with urlopen(request, timeout=25) as response:
            return json.load(response)

    try:
        account = auth('signUp', dict(email=email, password=password, returnSecureToken=True))
        token, uid = account['idToken'], account['localId']
        print('PASS: isolated test registration', flush=True)
        stage = 'save test name and avatar'
        result = auth('update', dict(idToken=token, displayName='EGY disposable UI test',
                                    photoUrl='https://avatars.egy.local/lotus', returnSecureToken=True))
        token = result.get('idToken', token)
        stage = 'restore test identity after sign-in'
        restored = auth('signInWithPassword', dict(email=email, password=password, returnSecureToken=True))
        assert restored['localId'] == uid
        token = restored['idToken']
        profile = auth('lookup', dict(idToken=token))['users'][0]
        assert profile['photoUrl'] == 'https://avatars.egy.local/lotus'
        assert profile['displayName'] == 'EGY disposable UI test'
        print('PASS: name/avatar persisted across fresh sign-in', flush=True)
        stage = 'change test password'
        changed = auth('update', dict(idToken=token, password=replacement, returnSecureToken=True))
        token = changed.get('idToken', token)
        try:
            auth('signInWithPassword', dict(email=email, password=password, returnSecureToken=True))
            raise AssertionError('Old test password accepted')
        except HTTPError as error:
            assert error.code == 400
        restored = auth('signInWithPassword', dict(email=email, password=replacement, returnSecureToken=True))
        assert restored['localId'] == uid
        token = restored['idToken']
        print('PASS: changed password works; old password rejected', flush=True)
        stage = 'check test UID cloud profile access'
        request = Request(f'https://firestore.googleapis.com/v1/projects/{project}/databases/(default)/documents/users/{uid}',
                          headers={'Authorization': 'Bearer ' + token})
        try:
            with urlopen(request, timeout=25):
                print('INFO: cloud profile read allowed', flush=True)
        except HTTPError as error:
            if error.code == 403:
                print('CONFIRMED BLOCKER: deployed rules deny user-profile access; account deletion preflight must stop.', flush=True)
            elif error.code == 404:
                print('INFO: test UID has no cloud profile record', flush=True)
            else:
                raise
    except Exception as error:
        print('FAIL: ' + stage + ' (' + type(error).__name__ + ')', flush=True)
        if isinstance(error, HTTPError):
            try:
                code = json.load(error).get('error', {}).get('message', '')
                safe = code if re.fullmatch(r'[A-Z_0-9]+', code) else 'REMOTE_REQUEST_REJECTED'
                print('Diagnostic: HTTP ' + str(error.code) + ' / ' + safe, flush=True)
            except Exception:
                print('Diagnostic: HTTP ' + str(error.code), flush=True)
        return 1
    finally:
        if token and uid:
            try:
                actual = auth('lookup', dict(idToken=token))['users'][0]['localId']
                assert actual == uid
                auth('delete', dict(idToken=token))
                print('PASS: disposable Auth account deleted; real phone session untouched', flush=True)
            except Exception:
                print('CLEANUP REQUIRED: disposable test UID ' + uid, flush=True)
                return 2
    return 0


if __name__ == '__main__':
    sys.exit(main())
