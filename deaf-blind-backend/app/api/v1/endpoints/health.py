"""Health check — also verifies the DB connection."""
from fastapi import APIRouter, Depends
from sqlalchemy import text
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.config import settings
from app.db.session import get_db

router = APIRouter(tags=["health"])


@router.get("/health")
async def health(db: AsyncSession = Depends(get_db)):
    try:
        await db.execute(text("SELECT 1"))
        db_status = "connected"
    except Exception as e:  # noqa: BLE001
        db_status = f"error: {e}"
    return {"status": "healthy", "env": settings.ENV, "db": db_status}
