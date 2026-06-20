"""§6 Process a video: extract audio -> STT -> text_to_sign (translation_engine).

Runs as a background task (app/tasks/video_processing.py).
"""
from app.services.translation_engine import pipeline  # noqa: F401


async def process(job_id: int) -> None:
    """Extract audio, transcribe, map to avatar sequence, save to VideoJob. Stub."""
    raise NotImplementedError
