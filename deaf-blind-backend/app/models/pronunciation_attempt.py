"""§4 PronunciationAttempt — an opt-in spoken-articulation attempt + feedback."""
from sqlalchemy.orm import Mapped, mapped_column

from app.db.base import Base


class PronunciationAttempt(Base):
    __tablename__ = "pronunciation_attempts"

    id: Mapped[int] = mapped_column(primary_key=True)
    # student_id (FK), target_phoneme, audio_url, feedback_text, created_at
