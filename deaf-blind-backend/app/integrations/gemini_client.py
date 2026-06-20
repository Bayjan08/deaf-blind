"""Gemini LLM client (§5 AI controller recommendations, optional translation assist)."""
import google.generativeai as genai
from app.core.config import settings

class GeminiClient:
    def __init__(self) -> None:
        if not settings.GEMINI_API_KEY:
            raise ValueError(
                "GEMINI_API_KEY is not configured. Please add it to your .env file."
            )
        genai.configure(api_key=settings.GEMINI_API_KEY)
        self.model = genai.GenerativeModel('gemini-1.5-flash')

    async def summarize(self, prompt: str) -> str:
        """Send a prompt to Gemini and return the text response asynchronously."""
        response = await self.model.generate_content_async(prompt)
        return response.text

    async def transcribe_audio(self, audio_bytes: bytes, mime_type: str = "audio/wav") -> str:
        """Transcribe and translate an audio file to text."""
        prompt = "Пожалуйста, расшифруй это голосовое сообщение и переведи его в понятный текст на русском языке."
        
        # GenerativeModel handles bytes directly if formatted nicely, 
        # or we upload it. Since it's bytes:
        content = [
            {"mime_type": mime_type, "data": audio_bytes},
            prompt
        ]
        response = await self.model.generate_content_async(content)
        return response.text

    async def translate_gestures(self, gestures: list[str]) -> str:
        """Translate a sequence of gesture labels into a coherent sentence."""
        prompt = (
            "Ты сурдопереводчик. Тебе дают последовательность распознанных жестов (слов). "
            "Тебе нужно составить из них одно связное, грамотное предложение на русском языке.\n"
            f"Жесты: {', '.join(gestures)}"
        )
        response = await self.model.generate_content_async(prompt)
        return response.text

