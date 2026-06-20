"""Database initialization helpers (create tables, seed fixed vocabulary).

In production schema changes go through Alembic migrations; this is for local
bootstrapping and seeding the demo data (fixed sign vocabulary, alphabet, notes).
"""
from app.db.base import Base
from app.db.connector import get_engine


async def create_all() -> None:
    """Create all tables from the ORM metadata (local/dev convenience)."""
    async with get_engine().begin() as conn:
        await conn.run_sync(Base.metadata.create_all)


async def seed_demo_data() -> None:
    """Seed fixed vocabulary, alphabet letters, and musical notes for the demo."""
    raise NotImplementedError
