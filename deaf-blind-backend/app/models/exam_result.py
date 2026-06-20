"""§2 ExamResult — outcome of an end-of-level exam (unlocks next level)."""
from sqlalchemy.orm import Mapped, mapped_column

from app.db.base import Base


class ExamResult(Base):
    __tablename__ = "exam_results"

    id: Mapped[int] = mapped_column(primary_key=True)
    # student_id (FK), level_id (FK), score, passed, taken_at
