"""§7 Standalone AI translator agent (thin wrapper over translation_engine)."""
from fastapi import APIRouter

router = APIRouter(prefix="/ai-translator", tags=["ai-translator"])


@router.post("/translate")
async def translate():
    """General-purpose translate: speech/sign/text -> requested target. Stub."""
    raise NotImplementedError
