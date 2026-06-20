"""§5 Personal AI controller schemas."""
from app.schemas.common import ORMModel


class DashboardResponse(ORMModel):
    summary: str
    weak_areas: list[str]
    suggested_lessons: list[str]
    trend: str  # "improving" | "declining" | "steady"
