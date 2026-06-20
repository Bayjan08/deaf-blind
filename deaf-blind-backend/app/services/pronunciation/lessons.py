"""§4 Lesson content for the camera mouth-shape feature.

Thin wrapper over `visemes` so the endpoint layer stays declarative.
"""
from app.services.pronunciation import visemes


def get_lesson(key: str) -> dict:
    """Return the lesson payload (ranges, copy, haptic stress cue) for `key`."""
    return visemes.lesson(key)
