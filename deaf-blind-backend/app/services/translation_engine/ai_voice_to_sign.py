"""§7 Voice -> meaningful sign-gesture flow using Gemini (audio in, gloss out).

One multimodal call: Gemini listens to the Russian speech clip and returns
both the literal transcript and an ordered gloss sequence restricted to
`sign_assets.ASSET_VOCABULARY`, so the mobile avatar can play a meaningful
one-by-one gesture flow for the whole sentence immediately.
"""
from __future__ import annotations

import json
import logging

from app.services.translation_engine.sign_assets import is_known, known_words

logger = logging.getLogger(__name__)

_TRANSCRIBE_PROMPT = """\
Ты — распознаватель речи. В аудио — фраза на русском языке.
Расшифруй её точно как есть, без изменений и пояснений.
Верни ТОЛЬКО распознанный текст."""

_VOICE_TO_SIGN_PROMPT = """\
Ты — переводчик с русской речи на русский жестовый язык (РЖЯ).
В аудио — фраза на русском языке.

1. Расшифруй фразу как есть (поле "text").
2. Переведи её смысл в порядок жестов для аватара (поле "words"), используя
   ТОЛЬКО слова из этого списка, в естественном для РЖЯ порядке показа:
   {vocab}

Если в фразе есть смысл, не покрытый списком, выбери самые близкие по смыслу
слова из списка или пропусти их. Не придумывай слова вне списка.

Верни ТОЛЬКО JSON без пояснений и без markdown, в формате:
{{"text": "...", "words": ["...", "..."]}}"""


async def transcribe(audio_bytes: bytes, mime_type: str) -> str:
    """Audio -> literal Russian transcript (no gloss)."""
    from app.integrations.gemini_client import GeminiClient

    client = GeminiClient()
    result = await client.generate_with_audio(_TRANSCRIBE_PROMPT, audio_bytes, mime_type)
    return result.strip()


async def transcribe_and_gloss(audio_bytes: bytes, mime_type: str) -> tuple[str, list[str]]:
    """Audio -> (literal transcript, ordered gloss words from the known sign vocabulary)."""
    from app.integrations.gemini_client import GeminiClient

    client = GeminiClient()
    prompt = _VOICE_TO_SIGN_PROMPT.format(vocab=", ".join(known_words()))
    raw = await client.generate_with_audio(prompt, audio_bytes, mime_type)
    return _parse_response(raw)


def _parse_response(raw: str) -> tuple[str, list[str]]:
    cleaned = raw.strip()
    if cleaned.startswith("```"):
        cleaned = cleaned.strip("`")
        if cleaned.lower().startswith("json"):
            cleaned = cleaned[4:]
    try:
        data = json.loads(cleaned)
        text = str(data.get("text", "")).strip()
        words = [w.strip() for w in data.get("words", []) if isinstance(w, str)]
        return text, [w for w in words if is_known(w)]
    except (json.JSONDecodeError, AttributeError) as exc:
        logger.warning("Gemini voice-to-sign returned non-JSON: %s — %r", exc, raw[:200])
        return cleaned, []
