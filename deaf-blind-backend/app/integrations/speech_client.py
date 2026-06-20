"""Google Speech client — speech-to-text and text-to-speech (§1, §4, §6)."""
from app.core.config import settings


class SpeechClient:
    def __init__(self) -> None:
        self.api_key = settings.GOOGLE_SPEECH_API_KEY

    async def transcribe(self, audio: bytes, language: str = "ru") -> str:
        """Speech -> text. Stub."""
        raise NotImplementedError

    async def synthesize(self, text: str, language: str = "ru") -> bytes:
        """Text -> speech audio. Stub."""
        raise NotImplementedError
