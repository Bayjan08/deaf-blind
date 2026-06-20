"""§8.1 Translation engine orchestrator — the single shared entry point.

Used by §1 (live class), §6 (video upload), §7 (AI agent). Routes a request by
direction (speech/text/sign -> sign/text/speech) to the right submodule so the
three feature surfaces stay thin and never duplicate logic.
"""
from app.services.translation_engine import sign_to_text, stt, text_to_sign, tts


async def speech_to_sign(audio: bytes, language: str = "ru") -> list[int]:
    text = await stt.transcribe(audio, language)
    return await text_to_sign.to_animation_ids(text, language)


async def sign_to_speech(labels: list[str], language: str = "ru") -> bytes:
    text = await sign_to_text.labels_to_text(labels)
    return await tts.synthesize(text, language)
