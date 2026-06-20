"""§5 Personal AI controller dashboard."""
from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.dependencies.auth import get_current_user
from app.core.security import TokenPayload
from app.db.session import get_db
from app.schemas.ai_controller import DashboardResponse
from app.services.ai_controller import recommendations

router = APIRouter(prefix="/ai-controller", tags=["ai-controller"])


@router.get("/dashboard", response_model=DashboardResponse)
async def dashboard(
    user: TokenPayload = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Weak sounds + next-word recommendations + trend for the student."""
    return await recommendations.recommend(db, user.user_id)
