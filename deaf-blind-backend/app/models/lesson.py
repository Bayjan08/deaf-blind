"""§2 Lesson — a unit within a level (e.g. one letter lesson)."""
from sqlalchemy.orm import Mapped, mapped_column

from app.db.base import Base


class Lesson(Base):
    __tablename__ = "lessons"

    id: Mapped[int] = mapped_column(primary_key=True)
    # level_id (FK), order_index, letter_id (FK, nullable)
