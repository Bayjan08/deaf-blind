"""§4 AI sound feedback for pronunciation attempts (voice-only, no teacher).

Gives direct, automated pronunciation feedback from the recorded audio clip via
Gemini — independent of the geometric mouth-shape score in `feedback.py`.
Degrades gracefully: if Gemini isn't configured or the call fails, no AI
feedback is returned and the mouth-shape result still stands on its own.
"""
from __future__ import annotations

import logging

from app.integrations.gemini_client import GeminiClient

logger = logging.getLogger(__name__)

_SYSTEM_INSTRUCTION = (
    "You are a friendly, encouraging speech coach for a deaf or hard-of-hearing "
    "learner practicing spoken pronunciation. Listen to the short audio clip and "
    "give very short (1-2 sentences), concrete, kind feedback on how clearly they "
    "produced the target sound. If the clip is silent or has no clear attempt, "
    "gently ask them to try again with their voice. Reply with the feedback only, "
    "no preamble or extra commentary."
)


async def analyze(word: str, phoneme: str, audio_bytes: bytes, mime_type: str) -> str | None:
    """Return short AI feedback text for the clip, or None if unavailable."""
    if not audio_bytes:
        return None
    prompt = f'The learner is trying to say "{word}" (target sound {phoneme}).'
    try:
        text = await GeminiClient().generate_with_audio(
            prompt,
            audio_bytes=audio_bytes,
            mime_type=mime_type,
            system_instruction=_SYSTEM_INSTRUCTION,
        )
        return text.strip() or None
    except Exception:
        logger.exception("Voice AI feedback failed")
        return None
