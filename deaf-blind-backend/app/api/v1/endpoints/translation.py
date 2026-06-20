"""§1/§6/§7 Shared translation engine REST surface."""
from fastapi import APIRouter, UploadFile, File
from pydantic import BaseModel
from typing import List

from app.integrations.gemini_client import GeminiClient

router = APIRouter(prefix="/translation", tags=["translation"])
gemini_client = GeminiClient()

class SignToTextRequest(BaseModel):
    gestures: List[str]

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
async def text_to_sign():
    """Text -> ordered avatar animation ids. Stub."""
    raise NotImplementedError
