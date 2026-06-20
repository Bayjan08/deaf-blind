"""§5 Personal AI controller dashboard."""
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel

from app.services.ai_controller import recommendations as rec_svc

router = APIRouter(prefix="/ai-controller", tags=["ai-controller"])


class StudentSummary(BaseModel):
    letters_mastered: list[str] = []
    letters_struggling: list[str] = []
    music_sessions: int = 0
    pronunciation_score: float = 0.0
    total_practice_minutes: int = 0


class RecommendationResponse(BaseModel):
    recommendation: str


@router.post("/recommend", response_model=RecommendationResponse)
async def get_recommendation(summary: StudentSummary):
    """Send student performance to Gemini, get back learning recommendations."""
    try:
        text = await rec_svc.recommend(summary.model_dump())
        return RecommendationResponse(recommendation=text)
    except ValueError as e:
        # Gemini not configured yet
        raise HTTPException(status_code=503, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"AI error: {e}")


@router.get("/dashboard")
async def dashboard():
    """Stub: full dashboard aggregating analytics + Gemini insights. Coming soon."""
    return {"status": "stub — implement analytics aggregation then call /recommend"}
