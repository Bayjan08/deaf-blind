"""§5 Aggregate pronunciation attempts into strengths/weaknesses + trend.

v1 reads `pronunciation_attempts` directly (per-viseme average coarse score and
counts) rather than the lesson-oriented PerformanceLog, which is still a stub.
"""
from __future__ import annotations

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.pronunciation_attempt import PronunciationAttempt

# A viseme is "weak" when the student's average shape score stays below this.
_WEAK_THRESHOLD = 0.6


async def summarize_performance(db: AsyncSession, student_id: str) -> dict:
    """Compute weak visemes, strong visemes, attempt totals and a trend."""
    rows = (
        await db.execute(
            select(
                PronunciationAttempt.target_viseme,
                PronunciationAttempt.coarse_score,
                PronunciationAttempt.created_at,
            )
            .where(PronunciationAttempt.student_id == student_id)
            .order_by(PronunciationAttempt.created_at.asc())
        )
    ).all()

    if not rows:
        return {
            "weak_visemes": [],
            "strong_visemes": [],
            "total_attempts": 0,
            "trend": "steady",
        }

    by_viseme: dict[str, list[float]] = {}
    for viseme, score, _created in rows:
        by_viseme.setdefault(viseme, []).append(score)

    weak = sorted(
        (v for v, s in by_viseme.items() if (sum(s) / len(s)) < _WEAK_THRESHOLD),
        key=lambda v: sum(by_viseme[v]) / len(by_viseme[v]),
    )
    strong = [v for v, s in by_viseme.items() if (sum(s) / len(s)) >= _WEAK_THRESHOLD]

    scores = [score for _v, score, _c in rows]
    trend = _trend(scores)

    return {
        "weak_visemes": weak,
        "strong_visemes": strong,
        "total_attempts": len(rows),
        "trend": trend,
    }


def _trend(scores: list[float]) -> str:
    """Compare the recent half of attempts to the earlier half."""
    if len(scores) < 4:
        return "steady"
    mid = len(scores) // 2
    older = sum(scores[:mid]) / mid
    recent = sum(scores[mid:]) / (len(scores) - mid)
    if recent - older > 0.07:
        return "improving"
    if older - recent > 0.07:
        return "declining"
    return "steady"
