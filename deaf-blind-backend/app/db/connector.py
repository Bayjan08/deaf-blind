"""Database engine creation.

- On Cloud Run (K_SERVICE set): Cloud SQL Python Connector — no public IP.
- Locally: direct TCP to the Cloud SQL public IP via DB_HOST.

The engine is created lazily so the app boots even if the DB is unreachable.
"""
from sqlalchemy import URL
from sqlalchemy.ext.asyncio import AsyncEngine, create_async_engine

from app.core.config import settings

_engine: AsyncEngine | None = None


def get_engine() -> AsyncEngine:
    global _engine
    if _engine is None:
        _engine = _make_engine()
    return _engine


def _make_engine() -> AsyncEngine:
    if settings.on_cloud_run:
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

    if not settings.DB_HOST:
        raise RuntimeError("Set DB_HOST in .env to the Cloud SQL public IP for local dev.")

    url = URL.create(
        "postgresql+asyncpg",
        username=settings.DB_USER,
        password=settings.DB_PASS,
        host=settings.DB_HOST,
        port=settings.DB_PORT,
        database=settings.DB_NAME,
    )
    return create_async_engine(url, pool_size=5, max_overflow=2, pool_pre_ping=True)
