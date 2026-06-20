"""§4 Pronunciation (optional) schemas."""
from app.schemas.common import ORMModel


class PronunciationFeedback(ORMModel):
    target_phoneme: str
    feedback_text: str
