"""In-memory sessions bound to verified Firebase UIDs; one writer per session."""
from __future__ import annotations
import threading
import time
import uuid
from dataclasses import dataclass, field
from fastapi import HTTPException
from core.config import settings
from src.chatbot.chat_engine import ChatSession, LLMClient

@dataclass
class _Entry:
    session: ChatSession
    owner: str
    touched: float
    lock: threading.Lock = field(default_factory=threading.Lock)

class SessionManager:
    """Single-process storage. A UUID alone never grants conversation access."""
    def __init__(self, ttl: int | None = None):
        self._ttl = ttl if ttl is not None else settings.session_ttl_seconds
        self._sessions: dict[str, _Entry] = {}
        self._lock = threading.Lock()

    def get_or_create(self, session_id: str | None, llm_client: LLMClient,
                      *, owner_uid: str) -> tuple[ChatSession, str]:
        if not owner_uid:
            raise HTTPException(401, 'Verified user required')
        with self._lock:
            now = time.monotonic()
            stale = [sid for sid, entry in self._sessions.items()
                     if now - entry.touched > self._ttl and not entry.lock.locked()]
            for sid in stale:
                del self._sessions[sid]
            if session_id:
                entry = self._owned(session_id, owner_uid)
                entry.touched = now
                return entry.session, session_id
            new_id = str(uuid.uuid4())
            session = ChatSession(session_id=new_id, llm_client=llm_client)
            self._sessions[new_id] = _Entry(session, owner_uid, now)
            return session, new_id

    def _owned(self, session_id: str, owner_uid: str) -> _Entry:
        entry = self._sessions.get(session_id)
        if entry is None or entry.owner != owner_uid:
            raise HTTPException(404, 'Conversation not found or expired')
        return entry

    def send(self, session_id: str, owner_uid: str, message: str) -> dict:
        with self._lock:
            entry = self._owned(session_id, owner_uid)
        with entry.lock:
            try:
                return entry.session.send(message)
            finally:
                with self._lock:
                    entry.touched = time.monotonic()

    def reset_session(self, session_id: str, *, owner_uid: str) -> bool:
        with self._lock:
            entry = self._owned(session_id, owner_uid)
        with entry.lock:
            entry.session.reset()
        return True

    @property
    def active_count(self) -> int:
        with self._lock:
            return len(self._sessions)

    def clear(self) -> None:
        with self._lock:
            self._sessions.clear()
