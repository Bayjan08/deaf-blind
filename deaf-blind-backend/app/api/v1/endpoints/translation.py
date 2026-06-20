"""§1/§6/§7 Shared translation engine REST surface."""
from fastapi import APIRouter

from app.schemas.translation import SignToTextRequest, TextResponse, TextToSignRequest, SignSequenceResponse
from app.services.translation_engine import sign_to_text as sign_to_text_svc
from app.services.translation_engine import vocabulary

router = APIRouter(prefix="/translation", tags=["translation"])


@router.post("/sign-to-text", response_model=TextResponse)
async def sign_to_text(body: SignToTextRequest):
    """Recognized gesture labels → Russian text."""
    text = await sign_to_text_svc.labels_to_text(body.labels)
    return TextResponse(text=text)


@router.post("/text-to-sign", response_model=SignSequenceResponse)
async def text_to_sign(body: TextToSignRequest):
    """Russian text → ordered avatar animation ids (demo: one id per word)."""
    words = body.text.strip().split()
    ids: list[int] = []
    for word in words:
        idx = await vocabulary.lookup_by_text(word, body.language)
        ids.append(idx if idx is not None else 0)
    return SignSequenceResponse(avatar_animation_ids=ids)
