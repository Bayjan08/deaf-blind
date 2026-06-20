"""Text -> speech, via integrations.speech_client (§1 student gestures read aloud)."""
from app.integrations.speech_client import SpeechClient

_client = SpeechClient()


async def synthesize(text: str, language: str = "ru") -> bytes:
    return await _client.synthesize(text, language)
