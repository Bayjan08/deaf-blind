"""§2 PetHouse — the home/castle that upgrades as levels are completed."""
from sqlalchemy.orm import Mapped, mapped_column

from app.db.base import Base


class PetHouse(Base):
    __tablename__ = "pet_houses"

    id: Mapped[int] = mapped_column(primary_key=True)
    # pet_id (FK), stage (basic..castle)
