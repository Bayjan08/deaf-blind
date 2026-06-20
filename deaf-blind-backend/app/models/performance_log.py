"""§5 PerformanceLog — append-only record feeding the Personal AI Controller.

One row per lesson/exam outcome across ALL modules: {student, module, lesson,
result, attempts, confidence, timestamp}. Source data for analytics + LLM summary.
"""
from sqlalchemy.orm import Mapped, mapped_column

from app.db.base import Base


class PerformanceLog(Base):
    __tablename__ = "performance_logs"

    id: Mapped[int] = mapped_column(primary_key=True)
    # student_id, module, lesson_id, result, attempts, confidence, created_at
