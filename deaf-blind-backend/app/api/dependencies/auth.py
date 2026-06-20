"""FastAPI auth dependencies."""
from fastapi import Depends
from sqlalchemy.ext.asyncio import AsyncSession

from app.db.session import get_db


async def get_current_user(db: AsyncSession = Depends(get_db)):
    """Resolve the authenticated student/teacher from the request. Stub."""
    raise NotImplementedError


async def get_current_teacher(user=Depends(get_current_user)):
    """Require the current user to be a teacher. Stub."""
    raise NotImplementedError
