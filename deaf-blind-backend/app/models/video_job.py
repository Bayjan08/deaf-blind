"""§6 VideoJob — an uploaded-video translation job and its lifecycle."""
from sqlalchemy.orm import Mapped, mapped_column

from app.db.base import Base


class VideoJob(Base):
    __tablename__ = "video_jobs"

    id: Mapped[int] = mapped_column(primary_key=True)
    # student_id (FK), source_url, status (queued|processing|done|failed),
    # transcript, sign_sequence (avatar ids), created_at
