"""§4 Pronunciation — camera mouth-shape practice.

Visual-first speech practice for deaf/HoH sighted users: the device tracks the
mouth, derives metrics, and we return directional feedback. No face video is
ever uploaded — only derived metrics.
"""
from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.dependencies.auth import get_current_user
from app.core.security import TokenPayload
from app.db.session import get_db
from app.models.pronunciation_attempt import PronunciationAttempt
from app.schemas.pronunciation import (
    MouthAttemptRequest,
    PronunciationFeedback,
    PronunciationLesson,
)
from app.services.pronunciation import feedback, lessons, visemes

router = APIRouter(prefix="/pronunciation", tags=["pronunciation"])


@router.get("/lessons/{key}", response_model=PronunciationLesson)
async def get_lesson(key: str):
    """Target viseme ranges, example word, instructions and the haptic cue."""
    return lessons.get_lesson(key)


@router.post("/attempt", response_model=PronunciationFeedback)
async def submit_attempt(
    body: MouthAttemptRequest,
    user: TokenPayload = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Score derived mouth metrics, persist the attempt, return directional cues."""
    viseme = visemes.resolve(body.target_viseme)
    result = feedback.analyze(viseme, body.metrics)

    attempt = PronunciationAttempt(
        student_id=user.user_id,
        target_viseme=viseme,
        metrics=body.metrics,
        coarse_score=result["coarse_score"],
        feedback_text=result["feedback_text"],
    )
    db.add(attempt)
    await db.commit()

    return PronunciationFeedback(
        target_viseme=viseme,
        feedback_text=result["feedback_text"],
        cues=result["cues"],
    )
