"""Offline regression checks for verified-user conversation isolation."""
import os
os.environ['CHAT_ENABLED'] = 'false'
import unittest
from unittest.mock import patch
from fastapi import HTTPException
from core.sessions import SessionManager
from src.chatbot.chat_engine import FakeLLMClient

class SessionOwnershipTest(unittest.TestCase):
    def test_other_uid_cannot_resume_or_reset(self):
        manager = SessionManager()
        session, sid = manager.get_or_create(None, FakeLLMClient([]), owner_uid='owner')
        same, same_id = manager.get_or_create(sid, FakeLLMClient([]), owner_uid='owner')
        self.assertIs(same, session)
        self.assertEqual(sid, same_id)
        for action in [
            lambda: manager.get_or_create(sid, FakeLLMClient([]), owner_uid='other'),
            lambda: manager.reset_session(sid, owner_uid='other'),
            lambda: manager.send(sid, 'other', 'hello'),
        ]:
            with self.assertRaises(HTTPException) as error:
                action()
            self.assertEqual(error.exception.status_code, 404)

    def test_expired_session_fails_without_creating_replacement(self):
        manager = SessionManager(ttl=1)
        with patch('core.sessions.time.monotonic', return_value=0):
            _, sid = manager.get_or_create(None, FakeLLMClient([]), owner_uid='owner')
        with patch('core.sessions.time.monotonic', return_value=2):
            with self.assertRaises(HTTPException):
                manager.get_or_create(sid, FakeLLMClient([]), owner_uid='owner')
        self.assertEqual(manager.active_count, 0)

    def test_missing_uid_is_rejected(self):
        with self.assertRaises(HTTPException) as error:
            SessionManager().get_or_create(None, FakeLLMClient([]), owner_uid='')
        self.assertEqual(error.exception.status_code, 401)

if __name__ == '__main__':
    unittest.main()
