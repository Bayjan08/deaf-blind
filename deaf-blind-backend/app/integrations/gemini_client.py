"""Gemini LLM client (§5 AI controller recommendations, optional translation assist)."""
from google import genai
from app.core.config import settings

class GeminiClient:
    def __init__(self) -> None:
        if not settings.GEMINI_API_KEY:
            raise ValueError(
                "GEMINI_API_KEY is not configured. Please add it to your .env file."
            )
        self.client = genai.Client(api_key=settings.GEMINI_API_KEY)

    async def summarize(self, prompt: str) -> str:
        """Send a prompt to Gemini and return the text response asynchronously."""
        response = await self.client.aio.models.generate_content(
            model='gemini-2.5-flash',
            contents=prompt,
        )
        return response.text
