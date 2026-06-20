"""Video meeting room metadata (LiveKit-backed)."""
from __future__ import annotations
from datetime import datetime

from sqlalchemy import DateTime, String, func
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.db.base import Base


class Meeting(Base):
    __tablename__ = "meetings"

    id: Mapped[str] = mapped_column(String(36), primary_key=True)
    title: Mapped[str] = mapped_column(String(200), nullable=False)
    host_id: Mapped[str] = mapped_column(String(128), nullable=False, index=True)
    code: Mapped[str] = mapped_column(String(8), unique=True, nullable=False, index=True)
    status: Mapped[str] = mapped_column(String(20), nullable=False, default="active")
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )
    ended_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))

    participants: Mapped[list["MeetingParticipant"]] = relationship(
        "MeetingParticipant",
        back_populates="meeting",
        cascade="all, delete-orphan",
    )
