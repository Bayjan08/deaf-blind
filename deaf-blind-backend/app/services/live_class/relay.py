"""§1 Relay translated captions/labels between peers (uses translation_engine).

Called by core/socket_events handlers; keeps socket layer thin.
"""
from app.services.translation_engine import pipeline  # noqa: F401


async def relay_caption(session_id: int, text: str) -> None:
    """Teacher caption -> student (text + optional sign animation). Stub."""
    raise NotImplementedError


async def relay_sign(session_id: int, labels: list[str]) -> None:
    """Student gesture labels -> teacher (text + optional TTS). Stub."""
    raise NotImplementedError
