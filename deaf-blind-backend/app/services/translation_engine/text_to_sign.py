"""Text -> sign. Maps text to an ordered list of avatar animation ids (§1/§6/§7).

ML-light by design: returns vocabulary animation ids; the mobile app plays the
matching pre-built Rive/Lottie clips.
"""
from app.services.translation_engine import vocabulary


async def to_animation_ids(text: str, language: str = "ru") -> list[int]:
    """Tokenize text and map each known token to its avatar animation id. Stub."""
    raise NotImplementedError
