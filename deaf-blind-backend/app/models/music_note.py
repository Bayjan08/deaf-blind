"""§3 MusicNote — note encoded as color + vibration pattern."""
from sqlalchemy.orm import Mapped, mapped_column

from app.db.base import Base


class MusicNote(Base):
    __tablename__ = "music_notes"

    id: Mapped[int] = mapped_column(primary_key=True)
    # name (C,D,E..), color_hex, vibration_hz, duration_ms, intensity
