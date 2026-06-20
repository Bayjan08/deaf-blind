"""§2 Pet — the student's companion that evolves with progression."""
from sqlalchemy.orm import Mapped, mapped_column

from app.db.base import Base


class Pet(Base):
    __tablename__ = "pets"

    id: Mapped[int] = mapped_column(primary_key=True)
    # student_id (FK), species, level, appearance_state
