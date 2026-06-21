"""§1/§6/§7 Translation engine schemas (shared)."""
from app.schemas.common import ORMModel


class TextToSignRequest(ORMModel):
    text: str
    language: str = "ru"


class SignSequenceResponse(ORMModel):
    avatar_animation_ids: list[int]  # ordered avatar clips for the mobile player


class SignToTextRequest(ORMModel):
    labels: list[str]  # recognized gesture labels from on-device classifier


class TextResponse(ORMModel):
    text: str


class VoiceToSignResponse(ORMModel):
    text: str          # literal transcript of the spoken sentence
    words: list[str]   # ordered gloss words to show on the avatar, one by one
