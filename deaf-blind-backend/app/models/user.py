"""User model — students and teachers."""
import enum
import uuid
from sqlalchemy import String
from sqlalchemy.orm import Mapped, mapped_column

from app.db.base import Base

class UserType(str, enum.Enum):
    DEAF = "deaf"
    BLIND = "blind"

class User(Base):
    __tablename__ = "users"

    id: Mapped[uuid.UUID] = mapped_column(primary_key=True, default=uuid.uuid4)
    email: Mapped[str] = mapped_column(String, unique=True, index=True)
    username: Mapped[str | None] = mapped_column(String, unique=True, index=True, nullable=True)
    password_hash: Mapped[str] = mapped_column(String)
    user_type: Mapped[UserType] = mapped_column(default=UserType.DEAF)

