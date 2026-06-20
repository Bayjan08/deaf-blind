"""§4 Score a camera mouth-shape attempt vs the target viseme (visual-first §4.4).

Mirrors the academy `gesture_check.check(...)` keystone: the device sends
*derived metrics/labels* (not raw media), and we return a small result. Scoring
is geometric (see `visemes.score`) — no audio, no trained model.
"""
from app.services.pronunciation import visemes


def analyze(target_viseme: str, metrics: dict[str, float]) -> dict:
    """Return {feedback_text, cues, coarse_score} for the attempt."""
    return visemes.score(target_viseme, metrics)
