"""§1/§6/§7 SignPhrase — fixed-vocabulary entry shared by the translation engine.

Maps a text token/phrase to a pre-built avatar animation asset. The demo ships a
small set (§1.7); expandable post-hackathon.
"""
from sqlalchemy.orm import Mapped, mapped_column

from app.db.base import Base


class SignPhrase(Base):
    __tablename__ = "sign_phrases"

    id: Mapped[int] = mapped_column(primary_key=True)
    # text, language, avatar_animation_id, gesture_label (classifier output)
