"""§5 Turn the analytics summary into recommendations via the Gemini LLM.

Degrades gracefully: if Gemini isn't configured (no VERTEX_SERVICE_ACCOUNT/ADC) or
there's no attempt history yet, we fall back to deterministic suggestions drawn
from the viseme catalogue so the dashboard always returns something useful.
"""
from __future__ import annotations

from sqlalchemy.ext.asyncio import AsyncSession

from app.integrations.gemini_client import GeminiClient
from app.services.ai_controller import analytics
from app.services.pronunciation import visemes

_SYSTEM_PROMPT = """
Ты — AI-наставник для школы жестового языка для глухих и слабослышащих.
Анализируй прогресс ученика и давай конкретные, мотивирующие рекомендации на русском языке.
Будь кратким (2-3 пункта), говори как добрый учитель.
""".strip()


async def recommend(db: AsyncSession, student_id: str) -> dict:
    """Return {summary, weak_areas, suggested_lessons, trend} for the student."""
    perf = await analytics.summarize_performance(db, student_id)
    weak: list[str] = perf["weak_visemes"]

    weak_areas = [_label(v) for v in weak]
    suggested = _fallback_words(weak)
    summary = _fallback_summary(perf)

    # Try Gemini for a friendlier summary + example sentences; never block on it.
    if weak:
        try:
            text = await GeminiClient().generate(_prompt(perf), system_instruction=_SYSTEM_PROMPT)
            if text and text.strip():
                summary = text.strip()
        except Exception:
            pass  # keep the deterministic fallback

    return {
        "summary": summary,
        "weak_areas": weak_areas,
        "suggested_lessons": suggested,
        "trend": perf["trend"],
    }


def _label(viseme: str) -> str:
    spec = visemes.VISEMES.get(viseme)
    return f"{spec['phoneme']} (as in \"{spec['word']}\")" if spec else viseme


def _fallback_words(weak: list[str]) -> list[str]:
    if not weak:
        return [spec["word"] for spec in list(visemes.VISEMES.values())[:3]]
    return [visemes.VISEMES[v]["word"] for v in weak if v in visemes.VISEMES]


def _fallback_summary(perf: dict) -> str:
    if perf["total_attempts"] == 0:
        return "No attempts yet — pick a sound and try it in front of the camera."
    if not perf["weak_visemes"]:
        return "Great work — your mouth shapes are looking accurate. Keep practicing!"
    return "A few sounds need work. Practice the suggested words a little each day."


def _prompt(perf: dict) -> str:
    weak = ", ".join(_label(v) for v in perf["weak_visemes"])
    return (
        "You are a friendly speech-practice coach for a deaf or hard-of-hearing "
        "learner who practices mouth shapes with a camera. The learner's weak "
        f"sounds are: {weak}. Trend: {perf['trend']}. In 2-3 short, encouraging "
        "sentences (no audio references, visual cues only), tell them what to "
        "focus on and give one simple example word per weak sound."
    )
