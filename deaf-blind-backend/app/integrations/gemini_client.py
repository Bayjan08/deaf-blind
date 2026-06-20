"""Gemini LLM client using google-genai SDK with Vertex AI and API key fallback."""
import os
import re
from google import genai
from google.oauth2 import service_account
from app.core.config import settings
from app.models.sign_phrase import SignPhrase

class GeminiClient:
    def __init__(self) -> None:
        # 1. Try using GEMINI_API_KEY if configured
        if settings.GEMINI_API_KEY:
            self.client = genai.Client(api_key=settings.GEMINI_API_KEY)
            self.vertexai = False
            self.model_name = settings.GEMINI_MODEL
        else:
            # 2. Try using service account credentials with Vertex AI
            json_path = settings.VERTEX_SERVICE_ACCOUNT
            if os.path.exists(json_path):
                credentials = service_account.Credentials.from_service_account_file(
                    json_path,
                    scopes=["https://www.googleapis.com/auth/cloud-platform"]
                )
                self.client = genai.Client(
                    credentials=credentials,
                    vertexai=True,
                    project=settings.GCP_PROJECT_ID,
                    location=settings.GCP_LOCATION
                )
                self.vertexai = True
                self.model_name = settings.GEMINI_MODEL
            else:
                raise ValueError(
                    "Neither GEMINI_API_KEY nor VERTEX_SERVICE_ACCOUNT credentials are configured."
                )

    async def summarize(self, prompt: str) -> str:
        """Send a prompt to Gemini and return the text response asynchronously."""
        response = await self.client.aio.models.generate_content(
            model=self.model_name,
            contents=prompt,
        )
        return response.text

    async def transcribe_audio(self, audio_bytes: bytes, mime_type: str = "audio/wav") -> str:
        """Transcribe and translate an audio file to text."""
        prompt = "Пожалуйста, расшифруй это голосовое сообщение и переведи его в понятный текст на русском языке."
        from google.genai import types
        part = types.Part.from_bytes(
            data=audio_bytes,
            mime_type=mime_type
        )
        response = await self.client.aio.models.generate_content(
            model=self.model_name,
            contents=[part, prompt]
        )
        return response.text

    async def translate_gestures(self, gestures: list[str]) -> str:
        """Translate a sequence of gesture labels into a coherent sentence."""
        prompt = (
            "Ты сурдопереводчик. Тебе дают последовательность распознанных жестов (слов). "
            "Тебе нужно составить из них одно связное, грамотное предложение на русском языке.\n"
            f"Жесты: {', '.join(gestures)}"
        )
        response = await self.client.aio.models.generate_content(
            model=self.model_name,
            contents=prompt
        )
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
        try:
            response = await self.client.aio.models.generate_content(
                model=self.model_name,
                contents=prompt
            )
            result = response.text.strip()
            print(f"[Gemini] Raw response: '{result}'")
            cleaned = re.sub(r'[`\[\]\s]', '', result)
            ids = []
            for item in cleaned.split(','):
                if item.isdigit():
                    ids.append(int(item))
            print(f"[Gemini] Parsed IDs: {ids}")
            return ids
        except Exception as e:
            print(f"[Gemini] Error generating gestures: {e}")
            if vocabulary:
                return [item.avatar_animation_id for item in vocabulary[:3]]
            return [2, 3, 4]
