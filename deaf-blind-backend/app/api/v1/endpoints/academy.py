"""§2 Alphabet game: levels, lessons, gesture check, exam, pets."""
from fastapi import APIRouter

router = APIRouter(prefix="/academy", tags=["academy"])


@router.get("/levels")
async def get_levels():
    raise NotImplementedError


@router.get("/lessons/{lesson_id}")
async def get_lesson(lesson_id: int):
    raise NotImplementedError


@router.post("/gesture-check")
async def gesture_check():
    raise NotImplementedError


@router.post("/exam/{level_id}/grade")
async def grade_exam(level_id: int):
    raise NotImplementedError


@router.post("/pets")
async def choose_pet():
    raise NotImplementedError
