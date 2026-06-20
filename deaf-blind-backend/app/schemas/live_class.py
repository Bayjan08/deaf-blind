"""§1 Live-class schemas."""
from app.schemas.common import ORMModel


class CreateSessionResponse(ORMModel):
    session_id: int
    room_code: str


class JoinSessionRequest(ORMModel):
    room_code: str
