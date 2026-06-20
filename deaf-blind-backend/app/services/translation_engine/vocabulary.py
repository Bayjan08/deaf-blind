"""§1.7 Fixed vocabulary loader/lookup — the demo-limited supported phrases.

Backs both directions: text<->gesture_label<->avatar_animation. Seeded from the
SignPhrase table. Expandable post-hackathon.
"""


async def lookup_by_text(text: str, language: str = "ru") -> int | None:
    """Return the avatar_animation_id for a known phrase, or None. Stub."""
    raise NotImplementedError


async def lookup_by_label(label: str) -> str | None:
    """Return the text for a recognized gesture label, or None. Stub."""
    raise NotImplementedError
