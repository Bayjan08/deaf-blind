"""§2/§5 StudentProgress — per-lesson progress and attempt counts."""
from sqlalchemy.orm import Mapped, mapped_column

from app.db.base import Base


class StudentProgress(Base):
    __tablename__ = "student_progress"

    id: Mapped[int] = mapped_column(primary_key=True)
    # student_id (FK), lesson_id (FK), status, attempts, last_confidence, updated_at
