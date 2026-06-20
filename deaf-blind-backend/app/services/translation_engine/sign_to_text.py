"""Sign -> text (§1/§7). Converts recognized gesture labels (or raw landmarks) to text.

Recognition runs on-device (mobile core/ml); the backend usually receives labels.
landmarks_to_label is an optional server-side classifier fallback.
"""
from app.services.translation_engine import vocabulary


async def labels_to_text(labels: list[str]) -> str:
    """Join recognized labels into text via the vocabulary. Stub."""
    raise NotImplementedError


async def landmarks_to_label(vectors: list[float]) -> str:
    """Optional server-side classification of MediaPipe landmark vectors. Stub."""
    raise NotImplementedError
