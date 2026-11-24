"""Fail-closed Firebase Admin authentication for protected API routers."""
from __future__ import annotations

import os
from functools import lru_cache

from fastapi import HTTPException, Request


@lru_cache(maxsize=1)
def _admin_app():
    import firebase_admin
    from firebase_admin import credentials

    if os.getenv("FIREBASE_AUTH_EMULATOR_HOST"):
        raise RuntimeError("Firebase Auth emulator is not supported here")
    return firebase_admin.initialize_app(
        credentials.ApplicationDefault(),
        {"projectId": "real-estate-e1418"}, name="egy-api")


def require_user(request: Request):
    """Verify signature, expiry, project, revocation and disabled-user status."""
    parts = request.headers.get("authorization", "").split()
    if len(parts) != 2 or parts[0].lower() != "bearer":
        raise HTTPException(401, "Firebase ID token required",
                            headers={"WWW-Authenticate": "Bearer"})
    try:
        from firebase_admin import auth
        app = _admin_app()
    except Exception:
        raise HTTPException(503, "Firebase Admin verification is not configured") from None
    try:
        claims = auth.verify_id_token(parts[1], app=app, check_revoked=True)
    except (auth.InvalidIdTokenError, auth.RevokedIdTokenError,
            auth.UserDisabledError, ValueError):
        raise HTTPException(401, "Invalid Firebase ID token",
                            headers={"WWW-Authenticate": "Bearer"}) from None
    except Exception:
        raise HTTPException(503, "Firebase token verification unavailable") from None
    request.state.firebase_user = claims
    return claims
