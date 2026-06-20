"""Async session factory and the FastAPI DB dependency."""
from sqlalchemy.ext.asyncio import AsyncSession, async_sessionmaker

from app.db.connector import get_engine

_session_factory: async_sessionmaker[AsyncSession] | None = None


def get_session_factory() -> async_sessionmaker[AsyncSession]:
    global _session_factory
    if _session_factory is None:
        _session_factory = async_sessionmaker(
            get_engine(), class_=AsyncSession, expire_on_commit=False
        )
    return _session_factory


async def get_db():
    """FastAPI dependency — yields a DB session per request."""
    async with get_session_factory()() as session:
        yield session
