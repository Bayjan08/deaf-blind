"""Database engine creation.

- Cloud Run or local without DB_HOST: Cloud SQL Python Connector (ADC / service account).
- Local with DB_HOST set: direct TCP to the Cloud SQL public IP.

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


def _connector_engine() -> AsyncEngine:
    from google.cloud.sql.connector import create_async_connector

    connector_holder: dict[str, object] = {}

    async def init_connector():
        if "connector" not in connector_holder:
            connector_holder["connector"] = await create_async_connector()

    async def getconn():
        await init_connector()
        connector = connector_holder["connector"]
        return await connector.connect_async(
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


def _tcp_engine() -> AsyncEngine:
    url = URL.create(
        "postgresql+asyncpg",
        username=settings.DB_USER,
        password=settings.DB_PASS,
        host=settings.DB_HOST,
        port=settings.DB_PORT,
        database=settings.DB_NAME,
    )
    return create_async_engine(url, pool_size=5, max_overflow=2, pool_pre_ping=True)


def _make_engine() -> AsyncEngine:
    if settings.use_cloud_sql_connector:
        if not settings.CLOUD_SQL_CONNECTION_NAME:
            raise RuntimeError(
                "Set CLOUD_SQL_CONNECTION_NAME in .env (project:region:instance)."
            )
        return _connector_engine()

    if not settings.db_host_configured:
        raise RuntimeError(
            "Set DB_HOST in .env to the Cloud SQL public IP, or set "
            "CLOUD_SQL_CONNECTION_NAME and run `gcloud auth application-default login`."
        )

    return _tcp_engine()
