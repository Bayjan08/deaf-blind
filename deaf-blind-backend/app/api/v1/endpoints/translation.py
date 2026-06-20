"""§1/§6/§7 Shared translation engine REST surface."""
from fastapi import APIRouter

router = APIRouter(prefix="/translation", tags=["translation"])


@router.post("/text-to-sign")
async def text_to_sign():
    """Text -> ordered avatar animation ids. Stub."""
    raise NotImplementedError


@router.post("/sign-to-text")
async def sign_to_text():
    """Recognized gesture labels -> text. Stub."""
    raise NotImplementedError
