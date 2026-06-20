"""Security helpers — JWT for API auth, LiveKit tokens generated in meeting service."""
from datetime import UTC, datetime, timedelta

import jwt
from fastapi import HTTPException, status

from app.core.config import settings


class TokenPayload:
    def __init__(self, user_id: str, display_name: str):
        self.user_id = user_id
        self.display_name = display_name


def create_access_token(user_id: str, display_name: str, *, expires_hours: int = 24) -> str:
    """Issue a signed JWT for authenticated API calls."""
    now = datetime.now(UTC)
    payload = {
        "sub": user_id,
        "name": display_name,
        "iat": now,
        "exp": now + timedelta(hours=expires_hours),
    }
    return jwt.encode(payload, settings.JWT_SECRET, algorithm=settings.JWT_ALGORITHM)


def decode_access_token(token: str) -> TokenPayload:
    """Validate JWT and return user claims."""
    try:
        data = jwt.decode(token, settings.JWT_SECRET, algorithms=[settings.JWT_ALGORITHM])
    except jwt.PyJWTError as exc:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or expired token",
        ) from exc

    user_id = data.get("sub")
    if not user_id:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid token payload",
        )
    return TokenPayload(user_id=str(user_id), display_name=str(data.get("name") or "Guest"))


async def verify_id_token(token: str) -> dict:
    """Verify a Firebase ID token and return its claims. Stub for future Firebase auth."""
    raise NotImplementedError
