"""§1/§6/§7 Shared translation engine REST surface."""
from fastapi import APIRouter, UploadFile, File, Depends
from pydantic import BaseModel
from typing import List
from sqlalchemy.ext.asyncio import AsyncSession

from app.integrations.gemini_client import GeminiClient
from app.db.session import get_db
from app.services.translation_engine.vocabulary import get_all_vocabulary

router = APIRouter(prefix="/translation", tags=["translation"])
gemini_client = GeminiClient()

class SignToTextRequest(BaseModel):
    gestures: List[str]

class TextToSignRequest(BaseModel):
    text: str
    language: str = "ru"

@router.post("/speech-to-text")
async def speech_to_text(audio: UploadFile = File(...)):
    """Convert spoken audio file to translated text using Gemini."""
    audio_bytes = await audio.read()
    mime_type = audio.content_type or "audio/wav"
    text = await gemini_client.transcribe_audio(audio_bytes, mime_type)
    return {"text": text}

@router.post("/sign-to-text")
async def sign_to_text(request: SignToTextRequest):
    """Recognized gesture labels -> coherent text sentence using Gemini."""
    text = await gemini_client.translate_gestures(request.gestures)
    return {"text": text}

@router.post("/text-to-sign")
async def text_to_sign(request: TextToSignRequest, db: AsyncSession = Depends(get_db)):
    """Text -> ordered avatar animation ids using Gemini."""
    vocabulary = await get_all_vocabulary(db, request.language)
    animation_ids = await gemini_client.text_to_gestures(request.text, vocabulary)
    return {"avatar_animation_ids": animation_ids}
