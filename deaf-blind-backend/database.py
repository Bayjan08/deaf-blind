"""Database engine setup.

- On Cloud Run (K_SERVICE is set): use the Cloud SQL Python Connector — no
  public IP, IAM-secured, recommended by Google.
- Locally: connect via TCP to the Cloud SQL public IP using DB_HOST.

The engine is created lazily so the app can boot even if the DB is unreachable.
"""
from sqlalchemy import URL
from sqlalchemy.ext.asyncio import AsyncSession, async_sessionmaker, create_async_engine
from sqlalchemy.orm import DeclarativeBase

from config import settings

_engine = None
_session_factory = None


def get_engine():
    global _engine
    if _engine is None:
        _engine = _make_engine()
    return _engine


def get_session_factory():
    global _session_factory
    if _session_factory is None:
        _session_factory = async_sessionmaker(
            get_engine(), class_=AsyncSession, expire_on_commit=False
        )
    return _session_factory


def _make_engine():
    if settings.on_cloud_run:
        # --- Cloud Run: Cloud SQL connector ---
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
            pool_pre_ping=True,
        )

    # --- Local dev: direct TCP to Cloud SQL public IP ---
    if not settings.DB_HOST:
        raise RuntimeError(
            "Set DB_HOST in deaf-blind-backend/.env to your Cloud SQL public IP "
            "for local development."
        )
    # URL.create safely handles passwords with special characters.
    url = URL.create(
        "postgresql+asyncpg",
        username=settings.DB_USER,
        password=settings.DB_PASS,
        host=settings.DB_HOST,
        port=settings.DB_PORT,
        database=settings.DB_NAME,
    )
    return create_async_engine(url, pool_size=5, max_overflow=2, pool_pre_ping=True)


class Base(DeclarativeBase):
    """Base class for all ORM models."""


async def get_db():
    """FastAPI dependency — yields a DB session per request."""
    async with get_session_factory()() as session:
        yield session
