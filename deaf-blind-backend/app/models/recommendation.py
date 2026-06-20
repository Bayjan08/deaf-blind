"""§5 Recommendation — LLM-generated next-step suggestion for a student."""
from sqlalchemy.orm import Mapped, mapped_column

from app.db.base import Base


class Recommendation(Base):
    __tablename__ = "recommendations"

    id: Mapped[int] = mapped_column(primary_key=True)
    # student_id (FK), summary, weak_areas, suggested_lessons, created_at
