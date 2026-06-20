"""§4 Optional pronunciation module."""
from fastapi import APIRouter

router = APIRouter(prefix="/pronunciation", tags=["pronunciation"])


@router.get("/lessons/{phoneme}")
async def get_lesson(phoneme: str):
    raise NotImplementedError


@router.post("/attempt")
async def submit_attempt():
    raise NotImplementedError
