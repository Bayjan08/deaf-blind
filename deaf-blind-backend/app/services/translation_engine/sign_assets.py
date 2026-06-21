"""Russian word -> bundled sign image asset.

Mirrors the PNG files shipped in the mobile app at
`deaf-blind-mobile/assets/images/signs/<value>.png`. The AI voice/text -> sign
pipeline constrains Gemini's gloss output to these words so every gesture in
the resulting flow has a real image to show on the avatar.
"""

ASSET_VOCABULARY: dict[str, str] = {
    "привет": "hello",
    "спасибо": "thank_you",
    "пожалуйста": "please",
    "стоп": "stop",
    "да": "yes",
    "нет": "no",
    "ты": "you",
    "я": "me",
    "хотеть": "want",
    "кушать": "eat",
    "вода": "water",
    "туалет": "toilet",
    "помощь": "help",
    "ещё": "more",
    "нравится": "like",
    "друзья": "friends",
    "играть": "play",
    "что": "what",
    "когда": "when",
    "где": "where",
    "кто": "who",
    "почему": "why",
    "нельзя": "dont",
    "готово": "all_done",
    "голодный": "hungry",
}


def is_known(word: str) -> bool:
    return word.strip().lower() in ASSET_VOCABULARY


def known_words() -> list[str]:
    return list(ASSET_VOCABULARY.keys())
