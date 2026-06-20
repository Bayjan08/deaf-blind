"""§4 Pronunciation — camera mouth-shape practice (letters, v1).

Visual-first speech practice for deaf/HoH sighted users: the device tracks the
mouth (MediaPipe in a WebView), derives metrics, and we return directional
feedback. The mouth shape judges the attempt; an optional audio clip is also
sent straight to Gemini for AI voice feedback shown to the student (no
teacher in the loop). No face video is ever uploaded.
"""
import json

from fastapi import APIRouter, Depends, File, Form, HTTPException, UploadFile, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.dependencies.auth import get_current_user
from app.core.security import TokenPayload
from app.db.session import get_db
from app.models.pronunciation_attempt import PronunciationAttempt
from app.schemas.pronunciation import (
    LetterEntry,
    PronunciationFeedback,
    PronunciationLesson,
)
from app.services.pronunciation import feedback, lessons, storage, visemes, voice_feedback

router = APIRouter(prefix="/pronunciation", tags=["pronunciation"])


@router.get("/letters", response_model=list[LetterEntry])
async def list_letters():
    """The catalogue of practiceable letters (v1 alphabet scope)."""
    return visemes.letters()


@router.get("/lessons/{key}", response_model=PronunciationLesson)
async def get_lesson(key: str):
    """Target viseme ranges, the letter/word, instructions and the haptic cue."""
    return lessons.get_lesson(key)


@router.post("/attempt", response_model=PronunciationFeedback)
async def submit_attempt(
    target_viseme: str = Form(...),
    metrics: str = Form(...),
    audio: UploadFile | None = File(None),
    user: TokenPayload = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Score derived mouth metrics, optionally store the audio clip, persist."""
    try:
        parsed: dict[str, float] = {
            k: float(v) for k, v in json.loads(metrics).items()
        }
    except (ValueError, TypeError) as exc:
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail="`metrics` must be a JSON object of metric -> number",
        ) from exc

    viseme = visemes.resolve(target_viseme)
    result = feedback.analyze(viseme, parsed)

    audio_bytes = await audio.read() if audio else b""
    audio_url = storage.save_audio(user.user_id, audio.filename if audio else None, audio_bytes)

    ai_feedback_text = None
    if audio_bytes:
        spec = visemes.VISEMES[viseme]
        mime_type = (audio.content_type or "") if audio else ""
        if not mime_type.startswith("audio/"):
            mime_type = "audio/wav"
        ai_feedback_text = await voice_feedback.analyze(
            word=spec["word"], phoneme=spec["phoneme"], audio_bytes=audio_bytes, mime_type=mime_type
        )

    attempt = PronunciationAttempt(
        student_id=user.user_id,
        target_viseme=viseme,
        metrics=parsed,
        coarse_score=result["coarse_score"],
        feedback_text=result["feedback_text"],
        audio_url=audio_url,
        ai_feedback_text=ai_feedback_text,
    )
    db.add(attempt)
    await db.commit()

    return PronunciationFeedback(
        target_viseme=viseme,
        feedback_text=result["feedback_text"],
        cues=result["cues"],
        audio_url=audio_url,
        ai_feedback_text=ai_feedback_text,
    )
