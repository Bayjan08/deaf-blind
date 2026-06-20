"""Auth endpoints (§ all) — Firebase token login."""
from fastapi import APIRouter

router = APIRouter(prefix="/auth", tags=["auth"])


@router.post("/login")
async def login():
    """Exchange a Firebase ID token for a session. Stub."""
    raise NotImplementedError
