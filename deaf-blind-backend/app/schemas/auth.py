"""Auth request/response schemas."""
from app.schemas.common import ORMModel


class LoginRequest(ORMModel):
    id_token: str  # Firebase ID token from the mobile app


class SessionResponse(ORMModel):
    user_id: int
    role: str
