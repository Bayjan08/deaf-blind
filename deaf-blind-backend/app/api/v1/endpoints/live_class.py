"""§1 Live-class REST (session create/join). Real-time relay is over Socket.IO."""
from fastapi import APIRouter

router = APIRouter(prefix="/live-class", tags=["live-class"])


@router.post("/sessions")
async def create_session():
    raise NotImplementedError


@router.post("/sessions/join")
async def join_session():
    raise NotImplementedError
