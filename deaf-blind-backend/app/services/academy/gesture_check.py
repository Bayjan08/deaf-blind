"""§2 Validate a practice gesture against the target letter.

Uses translation_engine.sign_to_text (on-device labels). Includes the demo
fallback (§2.5): after 3 attempts, auto-advance with encouragement.
"""
from app.services.translation_engine import sign_to_text  # noqa: F401

MAX_ATTEMPTS = 3


async def check(letter_id: int, labels: list[str]) -> dict:
    """Return {correct, confidence}. Stub."""
    raise NotImplementedError
