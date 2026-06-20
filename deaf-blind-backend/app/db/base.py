"""SQLAlchemy declarative base. All ORM models inherit from Base."""
from sqlalchemy.orm import DeclarativeBase


class Base(DeclarativeBase):
    """Base class for all ORM models."""
