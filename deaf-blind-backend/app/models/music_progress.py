"""§3 MusicProgress — recognition-game results per note."""
from sqlalchemy.orm import Mapped, mapped_column

from app.db.base import Base


class MusicProgress(Base):
    __tablename__ = "music_progress"

    id: Mapped[int] = mapped_column(primary_key=True)
    # student_id (FK), note_id (FK), correct_count, attempts, updated_at
