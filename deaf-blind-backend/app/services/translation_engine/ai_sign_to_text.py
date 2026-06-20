"""§7 AI-powered sign → text using Gemini (no fixed dictionary).

Two entry points:
- interpret_gesture()  — single gesture with 21 landmarks → one Russian word/phrase
- interpret_sequence() — list of labels → natural fluent Russian sentence
"""
from __future__ import annotations

import json
import logging

logger = logging.getLogger(__name__)

_GESTURE_PROMPT = """\
Ты — эксперт по жестовому языку (РЖЯ — Русский жестовый язык).
Тебе дают:
1. Короткое название жеста (подсказка): {label}
2. 21 нормализованную координату (x, y, z) ключевых точек кисти руки в формате MediaPipe Hands.

Данные landmarks:
{landmarks_json}

Определи, какое слово или фразу показывает этот жест на русском языке.
Верни ТОЛЬКО одно слово или короткую фразу на русском языке. Никаких объяснений."""

_SEQUENCE_PROMPT = """\
Ты — переводчик с жестового языка (РЖЯ) на русский.
Пользователь показал последовательность жестов (слов): {labels}

Составь из них одно естественное, грамматически правильное предложение на русском языке.
Сделай его звучащим живо и по-русски, не механическим переводом слово в слово.
Верни ТОЛЬКО готовое предложение, без кавычек и пояснений."""


def _fmt_landmarks(landmarks: list[dict]) -> str:
    """Format 21 landmarks as compact readable JSON for the prompt."""
    names = [
        "Запястье",
        "Большой_CMC", "Большой_MCP", "Большой_IP", "Большой_кончик",
        "Указ_MCP", "Указ_PIP", "Указ_DIP", "Указ_кончик",
        "Средн_MCP", "Средн_PIP", "Средн_DIP", "Средн_кончик",
        "Безым_MCP", "Безым_PIP", "Безым_DIP", "Безым_кончик",
        "Мизинец_MCP", "Мизинец_PIP", "Мизинец_DIP", "Мизинец_кончик",
    ]
    rows = []
    for i, lm in enumerate(landmarks[:21]):
        name = names[i] if i < len(names) else f"point_{i}"
        rows.append(f"  {name}: x={lm.get('x', 0):.3f}, y={lm.get('y', 0):.3f}, z={lm.get('z', 0):.3f}")
    return "\n".join(rows)


async def interpret_gesture(label: str, landmarks: list[dict]) -> str:
    """Send one gesture's landmarks to Gemini → Russian word/phrase."""
    from app.integrations.gemini_client import GeminiClient
    client = GeminiClient()
    prompt = _GESTURE_PROMPT.format(
        label=label,
        landmarks_json=_fmt_landmarks(landmarks),
    )
    try:
        result = await client.generate(prompt)
        return result.strip() or label
    except Exception as exc:
        logger.warning("Gemini interpret_gesture failed: %s — falling back to label", exc)
        return label


async def interpret_sequence(labels: list[str]) -> str:
    """Send a sequence of gesture labels to Gemini → natural Russian sentence."""
    if not labels:
        return ""
    if len(labels) == 1:
        return labels[0]

    from app.integrations.gemini_client import GeminiClient
    client = GeminiClient()
    prompt = _SEQUENCE_PROMPT.format(labels=", ".join(labels))
    try:
        result = await client.generate(prompt)
        return result.strip() or " ".join(labels)
    except Exception as exc:
        logger.warning("Gemini interpret_sequence failed: %s", exc)
        return " ".join(labels)
