"""Auth endpoints (§ all) — Firebase token login + dev JWT for local testing."""
from fastapi import APIRouter, HTTPException

from app.core.config import settings
from app.core.security import create_access_token
from app.schemas.meetings import DevTokenRequest, DevTokenResponse

router = APIRouter(prefix="/auth", tags=["auth"])


@router.post("/login")
async def login():
    """Exchange a Firebase ID token for a session. Stub."""
    raise NotImplementedError


@router.post("/dev-token", response_model=DevTokenResponse, include_in_schema=settings.ENV != "prod")
async def dev_token(body: DevTokenRequest):
    """Issue a JWT for local testing (disabled in production)."""
    if settings.ENV == "prod":
        raise HTTPException(status_code=404, detail="Not found")
    token = create_access_token(body.user_id, body.display_name)
    return DevTokenResponse(
        access_token=token,
        user_id=body.user_id,
        display_name=body.display_name,
    )
