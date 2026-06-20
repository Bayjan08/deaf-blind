"""§1 ClassSession — a live teacher<->student session room."""
from sqlalchemy.orm import Mapped, mapped_column

from app.db.base import Base


class ClassSession(Base):
    __tablename__ = "class_sessions"

    id: Mapped[int] = mapped_column(primary_key=True)
    # teacher_id (FK), room_code, status, started_at, ended_at
