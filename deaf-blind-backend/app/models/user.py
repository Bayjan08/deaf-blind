"""User model — students and teachers."""
from sqlalchemy.orm import Mapped, mapped_column

from app.db.base import Base


class User(Base):
    __tablename__ = "users"

    id: Mapped[int] = mapped_column(primary_key=True)
    # firebase_uid, role ("student"|"teacher"), display_name, locale, created_at
