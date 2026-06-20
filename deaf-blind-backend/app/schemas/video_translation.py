"""§6 Video-upload translation schemas."""
from app.schemas.common import ORMModel


class VideoJobOut(ORMModel):
    id: int
    status: str
    transcript: str | None = None
    sign_sequence: list[int] | None = None
