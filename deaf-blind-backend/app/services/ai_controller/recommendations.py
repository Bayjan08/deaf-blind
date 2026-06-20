"""§5 AI Controller — Gemini-powered learning recommendations.

Takes the student's performance summary and asks Gemini to suggest what to
practice next. GeminiClient is instantiated lazily so startup doesn't fail
when GEMINI_API_KEY isn't set yet.
"""
from __future__ import annotations

from app.integrations.gemini_client import GeminiClient

_SYSTEM_PROMPT = """
Ты — AI-наставник для школы жестового языка для глухих и слабослышащих.
Анализируй прогресс ученика и давай конкретные, мотивирующие рекомендации на русском языке.
Будь кратким (2-3 пункта), говори как добрый учитель.
""".strip()

_client: GeminiClient | None = None


def _get_client() -> GeminiClient:
    global _client
    if _client is None:
        _client = GeminiClient()
    return _client


async def recommend(student_summary: dict) -> str:
    """Ask Gemini to recommend the next learning steps for a student.

    student_summary keys (all optional, best-effort):
        letters_mastered: list[str]
        letters_struggling: list[str]
        music_sessions: int
        pronunciation_score: float   (0.0–1.0)
        total_practice_minutes: int
    """
    prompt = _build_prompt(student_summary)
    return await _get_client().generate(prompt, system_instruction=_SYSTEM_PROMPT)


def _build_prompt(s: dict) -> str:
    mastered = ", ".join(s.get("letters_mastered", [])) or "нет данных"
    struggling = ", ".join(s.get("letters_struggling", [])) or "нет данных"
    minutes = s.get("total_practice_minutes", 0)
    score = s.get("pronunciation_score", 0)
    music = s.get("music_sessions", 0)

    return (
        f"Ученик занимался {minutes} минут.\n"
        f"Освоил буквы: {mastered}.\n"
        f"Затрудняется с: {struggling}.\n"
        f"Сессий музыкальной вибрации: {music}.\n"
        f"Оценка произношения: {score:.0%}.\n\n"
        f"Что порекомендуешь изучить дальше?"
    )
