"""§2 Letter — alphabet item: glyph, illustrative image, sign-animation reference."""
from sqlalchemy.orm import Mapped, mapped_column

from app.db.base import Base


class Letter(Base):
    __tablename__ = "letters"

    id: Mapped[int] = mapped_column(primary_key=True)
    # glyph, example_word, image_url, sign_animation_id (-> SignPhrase/avatar asset)
