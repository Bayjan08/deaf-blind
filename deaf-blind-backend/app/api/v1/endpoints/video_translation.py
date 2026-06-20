"""§6 Video-upload translation."""
from fastapi import APIRouter

router = APIRouter(prefix="/video-translation", tags=["video-translation"])


@router.post("/jobs")
async def create_job():
    raise NotImplementedError


@router.get("/jobs/{job_id}")
async def get_job(job_id: int):
    raise NotImplementedError
