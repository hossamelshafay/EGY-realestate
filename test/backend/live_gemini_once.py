"""Explicit one-shot Gemini probe. Not part of unittest discovery."""
import json
import logging
import sys
from pathlib import Path
from unittest.mock import patch

ROOT = Path(__file__).resolve().parents[2] / 'EGY_DEVELOPMENT_ai'
sys.path.insert(0, str(ROOT))
from core.config import settings
from dotenv import dotenv_values
from google import genai
from google.genai import types
from src.chatbot.chat_engine import GeminiClient

logging.disable(logging.CRITICAL)

class StopProbe(BaseException):
    pass

def main():
    env = dotenv_values(settings.env_path)
    report = {
        'env_exists': settings.env_path.is_file(),
        'key_matches_env_file': bool(env.get('GEMINI_API_KEY')) and
            settings.gemini_api_key == env.get('GEMINI_API_KEY'),
        'chat_enabled': settings.chat_enabled,
        'configured_provider': settings.llm_provider,
        'selected_client': 'GeminiClient',
        'requested_model': settings.gemini_model,
        'generation_requests': 0,
    }
    assert report['key_matches_env_file'] and settings.chat_enabled
    marker = Path(__file__).with_name('gemini_once_result.json')
    if marker.exists():
        raise SystemExit('Probe already attempted; additional calls require approval.')
    marker.write_text(json.dumps({'status': 'started'}), encoding='utf-8')
    real_factory = genai.Client
    def factory(**kwargs):
        kwargs['http_options'] = types.HttpOptions(
            timeout=30000, retry_options=types.HttpRetryOptions(attempts=1))
        return real_factory(**kwargs)
    try:
        with patch.object(genai, 'Client', side_effect=factory):
            client = GeminiClient(settings.gemini_api_key, settings.gemini_model, timeout=30)
        actual_generate = client._client.models.generate_content
        def once(**kwargs):
            if report['generation_requests']:
                raise StopProbe('Second generation blocked')
            assert kwargs['model'] == settings.gemini_model
            config = kwargs['config']
            config.http_options.retry_options = types.HttpRetryOptions(attempts=1)
            config.automatic_function_calling = types.AutomaticFunctionCallingConfig(
                disable=True, maximum_remote_calls=0)
            report['generation_requests'] += 1
            try:
                response = actual_generate(**kwargs)
            except Exception as exc:
                report['error_type'] = type(exc).__name__
                report['error'] = str(exc).replace(settings.gemini_api_key, '[REDACTED]')
                raise StopProbe('Single generation failed; no retry or fallback') from None
            report['actual_model'] = response.model_version
            return response
        with patch.object(client._client.models, 'generate_content', side_effect=once):
            result = client.generate(
                [{'role': 'user', 'parts': [{'type': 'text', 'text': 'Reply with OK.'}]}],
                tools=[], system='Reply briefly. Do not call tools.', max_output_tokens=16)
        report['response'] = ''.join(p.get('text', '') for p in result['parts'])
        report['genuine_response'] = bool(report['response'].strip())
        report['usage'] = result['usage']
        client._client.close()
    except (Exception, StopProbe) as exc:
        report.setdefault('error_type', type(exc).__name__)
        report.setdefault('error', str(exc).replace(settings.gemini_api_key, '[REDACTED]'))
        report['genuine_response'] = False
    marker.write_text(json.dumps(report, indent=2), encoding='utf-8')
    print(json.dumps(report, indent=2))

if __name__ == '__main__':
    main()
