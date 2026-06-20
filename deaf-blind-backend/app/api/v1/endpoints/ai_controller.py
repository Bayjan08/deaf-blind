"""§5 Personal AI controller dashboard."""
from fastapi import APIRouter

router = APIRouter(prefix="/ai-controller", tags=["ai-controller"])


@router.get("/dashboard")
async def dashboard():
    """Strengths/weaknesses + trend + recommendations for the student. Stub."""
    raise NotImplementedError
