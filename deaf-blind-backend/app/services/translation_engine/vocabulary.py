"""§1.7 Fixed vocabulary — gesture label → Russian text (and reverse).

Demo vocabulary for the hackathon. Each entry is one gesture label that the
mobile classifier emits; the value is the Russian word/phrase displayed to the
user. Expandable post-hackathon via the SignPhrase DB table.
"""

# label (mobile sends this) → Russian meaning
SIGN_VOCABULARY: dict[str, str] = {
    # common phrases
    "hello": "привет",
    "bye": "пока",
    "thanks": "спасибо",
    "yes": "да",
    "no": "нет",
    "good": "хорошо",
    "bad": "плохо",
    "help": "помогите",
    "stop": "стоп",
    "love": "я тебя люблю",
    "sorry": "извини",
    "please": "пожалуйста",
    "understand": "понимаю",
    "repeat": "повтори",
    "wait": "подожди",
    # Russian alphabet (letters sent as-is)
    "А": "А", "Б": "Б", "В": "В", "Г": "Г", "Д": "Д",
    "Е": "Е", "Ж": "Ж", "З": "З", "И": "И", "К": "К",
    "Л": "Л", "М": "М", "Н": "Н", "О": "О", "П": "П",
    "Р": "Р", "С": "С", "Т": "Т", "У": "У", "Ф": "Ф",
}

# reverse: Russian word → label (for text-to-sign)
_TEXT_TO_LABEL: dict[str, str] = {v: k for k, v in SIGN_VOCABULARY.items()}


async def lookup_by_label(label: str) -> str | None:
    """Return the Russian text for a recognized gesture label, or None."""
    return SIGN_VOCABULARY.get(label)


async def lookup_by_text(text: str, language: str = "ru") -> int | None:
    """Return a vocabulary index for a known Russian word, or None."""
    label = _TEXT_TO_LABEL.get(text.lower())
    if label is None:
        return None
    keys = list(SIGN_VOCABULARY.keys())
    try:
        return keys.index(label)
    except ValueError:
        return None
