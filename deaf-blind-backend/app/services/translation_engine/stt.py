"""Speech -> text, via integrations.speech_client (§1 teacher audio, §6 video audio)."""
from app.integrations.speech_client import SpeechClient

_client = SpeechClient()


async def transcribe(audio: bytes, language: str = "ru") -> str:
    return await _client.transcribe(audio, language)
