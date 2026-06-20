"""Sign → text (§1/§7). Converts recognized gesture labels to Russian text.

Recognition runs on-device (mobile core/ml); backend receives the label strings
and maps them through the fixed vocabulary.
"""
from app.services.translation_engine import vocabulary


async def labels_to_text(labels: list[str]) -> str:
    """Join recognized labels into a Russian phrase via the vocabulary."""
    words: list[str] = []
    for label in labels:
        meaning = await vocabulary.lookup_by_label(label)
        words.append(meaning if meaning is not None else label)
    return " ".join(words)


async def landmarks_to_label(vectors: list[float]) -> str:
    """Optional server-side classification of MediaPipe landmark vectors. Stub."""
    raise NotImplementedError
