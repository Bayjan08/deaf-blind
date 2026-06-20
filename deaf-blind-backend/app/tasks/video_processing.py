"""§6 Background task: process an uploaded-video translation job.

Enqueued by the video_translation endpoint; calls services.video_translation.processing.
"""
from app.services.video_translation import processing


async def run(job_id: int) -> None:
    await processing.process(job_id)
