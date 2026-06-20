"""Gemini LLM client (§5 AI controller recommendations, optional translation assist)."""
from app.core.config import settings


class GeminiClient:
    def __init__(self) -> None:
        self.api_key = settings.GEMINI_API_KEY

    async def summarize(self, prompt: str) -> str:
        """Send a prompt to Gemini and return the text response. Stub."""
        raise NotImplementedError
