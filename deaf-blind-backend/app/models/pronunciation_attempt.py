"""§4 PronunciationAttempt — a camera mouth-shape attempt at a target viseme.

Stores only *derived* mouth metrics (never the face video, which stays on the
device — see §4.4). `coarse_score` is for internal progress tracking only and is
never surfaced to the user as a precision percentage.
"""
from __future__ import annotations

from datetime import datetime

from sqlalchemy import JSON, DateTime, Float, String, func
from sqlalchemy.orm import Mapped, mapped_column

from app.db.base import Base


class PronunciationAttempt(Base):
    __tablename__ = "pronunciation_attempts"

    id: Mapped[int] = mapped_column(primary_key=True, autoincrement=True)
    student_id: Mapped[str] = mapped_column(String(128), nullable=False, index=True)
    target_viseme: Mapped[str] = mapped_column(String(32), nullable=False, index=True)
    metrics: Mapped[dict] = mapped_column(JSON, nullable=False)
    coarse_score: Mapped[float] = mapped_column(Float, nullable=False, default=0.0)
    feedback_text: Mapped[str] = mapped_column(String(400), nullable=False, default="")
    # Optional recorded audio clip, archived for reference (never the face video).
    audio_url: Mapped[str | None] = mapped_column(String(512))
    # AI-generated pronunciation feedback from the audio clip (Gemini), shown to the student directly.
    ai_feedback_text: Mapped[str | None] = mapped_column(String(800))
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )
