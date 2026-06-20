"""§1/§6/§7 SignPhrase — fixed-vocabulary entry shared by the translation engine.

Maps a text token/phrase to a pre-built avatar animation asset. The demo ships a
small set (§1.7); expandable post-hackathon.
"""
from sqlalchemy import String, Integer
from sqlalchemy.orm import Mapped, mapped_column

from app.db.base import Base


class SignPhrase(Base):
    __tablename__ = "sign_phrases"

    id: Mapped[int] = mapped_column(primary_key=True)
    text: Mapped[str] = mapped_column(String, nullable=False)
    language: Mapped[str] = mapped_column(String, nullable=False, default="ru")
    avatar_animation_id: Mapped[int] = mapped_column(Integer, nullable=False)
    gesture_label: Mapped[str | None] = mapped_column(String, nullable=True)
