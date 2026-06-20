"""§3 Music-through-vibration schemas."""
from app.schemas.common import ORMModel


class NoteOut(ORMModel):
    id: int
    name: str
    color_hex: str
    vibration_hz: float
    duration_ms: int
    intensity: float
