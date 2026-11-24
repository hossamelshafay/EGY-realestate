"""Offline integration checks; no backend changes, credentials or provider calls.

Run from the backend root:
  .venv/Scripts/python.exe -m unittest discover -s ../test/backend -v
"""
import os
import socket
import unittest
from unittest.mock import patch

os.environ['CHAT_ENABLED'] = 'false'

from fastapi.testclient import TestClient
from app import app
from core.auth import require_user
from src.chatbot.chat_engine import ChatSession, FakeLLMClient
from src.chatbot.tools import search_properties


class OfflineAiIntegrationTest(unittest.TestCase):
    def setUp(self):
        original_connect = socket.socket.connect

        def offline_connect(sock, address):
            # Windows asyncio creates an internal loopback socket pair.
            if isinstance(address, tuple) and address[0] in ('127.0.0.1', '::1'):
                return original_connect(sock, address)
            raise AssertionError('External network forbidden')

        self.network = patch.object(
            socket.socket, 'connect', new=offline_connect
        )
        self.network.start()
        self.addCleanup(self.network.stop)
        app.dependency_overrides[require_user] = lambda: {'uid': 'offline-test'}
        self.addCleanup(app.dependency_overrides.clear)

    def test_real_recommendation_http_contract(self):
        with TestClient(app) as client:
            response = client.post('/api/recommendations/search', json={
                'category': 'buy', 'property_type': 'Apartment',
                'limit': 3, 'offset': 0,
            })
            self.assertEqual(response.status_code, 200, response.text)
            page = response.json()
            self.assertEqual(page['limit'], 3)
            self.assertGreater(page['total'], 0)
            self.assertEqual(len(page['items']), 3)
            for item in page['items']:
                self.assertEqual(item['category'], 'buy')
                self.assertEqual(item['property_type'], 'Apartment')
            property_id = page['items'][0]['id']
            response = client.get(
                f'/api/recommendations/similar/{property_id}?top_n=3'
            )
            self.assertEqual(response.status_code, 200, response.text)
            neighbors = response.json()
            self.assertEqual(neighbors['property_id'], property_id)
            self.assertGreater(len(neighbors['items']), 0)
            ids = [item['id'] for item in neighbors['items']]
            self.assertNotIn(property_id, ids)
            self.assertEqual(len(ids), len(set(ids)))

    def test_chat_tool_loop_uses_real_catalog(self):
        filters = {'category': 'buy', 'property_type': 'Apartment'}
        expected = search_properties(filters, limit=2)
        self.assertGreater(expected['total_matches'], 0)
        scripted = FakeLLMClient([
            {'tool_calls': [{'name': 'search_properties',
                             'args': {'filters': filters, 'limit': 2}}]},
            {'text': 'Here are matching apartments from the catalog.'},
        ])
        session = ChatSession(session_id='offline-chat', llm_client=scripted)
        result = session.send('Find an apartment to buy')
        self.assertTrue(result['reply'].strip())
        self.assertEqual(result['total_matches'], expected['total_matches'])
        self.assertEqual([p['id'] for p in result['properties']],
                         [p['id'] for p in expected['results']])

    def test_disabled_chat_never_initializes_provider(self):
        with TestClient(app) as client:
            self.assertIsNone(app.state.llm_client)
            response = client.post('/api/chat', json={'message': 'hello'})
            self.assertEqual(response.status_code, 503)


if __name__ == '__main__':
    unittest.main()
