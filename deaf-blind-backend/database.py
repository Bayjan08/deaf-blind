"""Database engine setup.

Local dev: connects via DATABASE_URL (direct TCP to Cloud SQL public IP).
Cloud Run: connects via Cloud SQL Python Connector (no public IP needed).
"""
from sqlalchemy.ext.asyncio import AsyncSession, async_sessionmaker, create_async_engine
from sqlalchemy.orm import DeclarativeBase

from config import settings

_engine = None
_SessionLocal = None


def get_engine():
    global _engine
    if _engine is None:
        _engine = _make_engine()
    return _engine


def get_session_factory():
    global _SessionLocal
    if _SessionLocal is None:
        _SessionLocal = async_sessionmaker(
            get_engine(), class_=AsyncSession, expire_on_commit=False
        )
    return _SessionLocal


def _make_engine():
    if settings.CLOUD_SQL_CONNECTION_NAME:
        # Running on Cloud Run — use the connector (no public IP required)
        from google.cloud.sql.connector import AsyncConnector

        connector = AsyncConnector()

        async def getconn():
            return await connector.connect(
                settings.CLOUD_SQL_CONNECTION_NAME,
                "asyncpg",
                user=settings.DB_USER,
                password=settings.DB_PASS,
                db=settings.DB_NAME,
            )

        return create_async_engine(
            "postgresql+asyncpg://",
            async_creator=getconn,
            pool_size=5,
            max_overflow=2,
        )
    else:
        if not settings.DATABASE_URL:
            raise RuntimeError(
                "Set DATABASE_URL in .env for local dev.\n"
                "Example: postgresql+asyncpg://postgres:pass@34.x.x.x:5432/deafblind"
            )
        return create_async_engine(settings.DATABASE_URL, pool_size=5, max_overflow=2)


class Base(DeclarativeBase):
    pass


async def get_db():
    """FastAPI dependency — yields a DB session per request."""
    async with get_session_factory()() as session:
        yield session
