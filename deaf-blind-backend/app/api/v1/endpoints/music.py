"""§3 Music through vibration: notes + recognition game."""
from fastapi import APIRouter

router = APIRouter(prefix="/music", tags=["music"])


@router.get("/notes")
async def get_notes():
    raise NotImplementedError


@router.post("/game/answer")
async def submit_answer():
    raise NotImplementedError
