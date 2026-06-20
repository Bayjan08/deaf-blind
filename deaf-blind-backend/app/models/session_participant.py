"""§1 SessionParticipant — a participant in a ClassSession."""
from sqlalchemy.orm import Mapped, mapped_column

from app.db.base import Base


class SessionParticipant(Base):
    __tablename__ = "session_participants"

    id: Mapped[int] = mapped_column(primary_key=True)
    # session_id (FK), user_id (FK), role, joined_at, left_at
