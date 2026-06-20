"""§7 Standalone AI translator agent schemas (reuses translation schemas)."""
from app.schemas.common import ORMModel


class TranslateRequest(ORMModel):
    mode: str  # "speech" | "sign" | "text"
    payload: str
    target: str  # "sign" | "text" | "speech"
