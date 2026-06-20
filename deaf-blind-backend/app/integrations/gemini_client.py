"""Gemini LLM client (§5 AI controller recommendations, optional translation assist)."""
import google.generativeai as genai
from app.core.config import settings
from app.models.sign_phrase import SignPhrase

class GeminiClient:
    def __init__(self) -> None:
        if not settings.GEMINI_API_KEY:
            raise ValueError(
                "GEMINI_API_KEY is not configured. Please add it to your .env file."
            )
        genai.configure(api_key=settings.GEMINI_API_KEY)
        self.model = genai.GenerativeModel('gemini-2.5-flash')

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

    async def text_to_gestures(self, text: str, vocabulary: list[SignPhrase]) -> list[int]:
        """Convert a sentence into a list of gesture IDs from a fixed vocabulary."""
        vocab_lines = "\n".join([f"{item.avatar_animation_id}: {item.text}" for item in vocabulary])
        prompt = (
            "У тебя есть словарь жестов (формат ID: значение):\n"
            f"{vocab_lines}\n\n"
            f"Преобразуй следующий текст в список соответствующих ID жестов, разделенных запятыми. "
            f"Выбери только наиболее подходящие жесты из словаря. "
            f"В ответе верни исключительно список чисел через запятую (например, '2,3,4') и больше вообще ничего. "
            f"Не пиши никаких пояснений, введений или знаков препинания кроме запятых.\n"
            f"Текст: {text}"
        )
        import re
        try:
            response = await self.model.generate_content_async(prompt)
            result = response.text.strip()
            print(f"[Gemini] Raw response: '{result}'")
            # Robust parsing of numbers
            # Remove any markdown code blocks or brackets
            cleaned = re.sub(r'[`\[\]\s]', '', result)
            # Find all numbers separated by commas or other non-digit delimiters
            ids = []
            for item in cleaned.split(','):
                if item.isdigit():
                    ids.append(int(item))
            print(f"[Gemini] Parsed IDs: {ids}")
            return ids
        except Exception as e:
            print(f"[Gemini] Error generating gestures: {e}")
            # Fallback mock using vocabulary
            if vocabulary:
                return [item.avatar_animation_id for item in vocabulary[:3]]
            return [2, 3, 4]


