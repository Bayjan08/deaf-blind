"""§2 Academy / alphabet-game schemas."""
from app.schemas.common import ORMModel


class LevelOut(ORMModel):
    id: int
    kind: str
    title: str
    unlocked: bool


class LetterOut(ORMModel):
    id: int
    glyph: str
    example_word: str
    image_url: str
    sign_animation_id: int


class GestureCheckRequest(ORMModel):
    letter_id: int
    labels: list[str]  # recognized gesture from on-device classifier


class GestureCheckResponse(ORMModel):
    correct: bool
    confidence: float
