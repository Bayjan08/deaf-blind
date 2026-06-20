"""§2 Level — Letters / Syllables / Words / Sentences nodes on the map."""
from sqlalchemy.orm import Mapped, mapped_column

from app.db.base import Base


class Level(Base):
    __tablename__ = "levels"

    id: Mapped[int] = mapped_column(primary_key=True)
    # order_index, kind ("letters"|"syllables"|"words"|"sentences"), title
