"""§4 Pronunciation (camera mouth-shape) schemas."""
from app.schemas.common import ORMModel


class StressBeat(ORMModel):
    """One haptic pulse in the stress/rhythm cue (NotePattern shape)."""
    name: str
    colorHex: int
    vibrationHz: float
    durationMs: int
    intensity: float


class PronunciationLesson(ORMModel):
    viseme: str
    letter: str | None = None
    word: str
    phoneme: str
    instructions: str
    # metric -> [min, max], normalized by interocular distance.
    target_metrics: dict[str, list[float]]
    stress_pattern: list[StressBeat]


class LetterEntry(ORMModel):
    letter: str
    viseme: str
    example: str


class PronunciationFeedback(ORMModel):
    target_viseme: str
    feedback_text: str
    cues: list[str] = []
    audio_url: str | None = None
    ai_feedback_text: str | None = None
