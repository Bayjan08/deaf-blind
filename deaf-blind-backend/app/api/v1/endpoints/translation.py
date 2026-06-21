"""§1/§6/§7 Shared translation engine REST surface."""
from __future__ import annotations

from typing import Any

from fastapi import APIRouter, File, HTTPException, UploadFile
from pydantic import BaseModel

from app.schemas.translation import (
    SignToTextRequest,
    TextResponse,
    TextToSignRequest,
    SignSequenceResponse,
    VoiceToSignResponse,
)
from app.services.translation_engine import sign_to_text as sign_to_text_svc
from app.services.translation_engine import vocabulary
from app.services.translation_engine import ai_sign_to_text as ai_svc
from app.services.translation_engine import ai_voice_to_sign
import asyncio
import logging

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/translation", tags=["translation"])


# ── dictionary-based (kept for live-class relay speed) ───────────────────────

@router.post("/sign-to-text", response_model=TextResponse)
async def sign_to_text(body: SignToTextRequest):
    """Recognized gesture labels → Russian text (dictionary lookup)."""
    text = await sign_to_text_svc.labels_to_text(body.labels)
    return TextResponse(text=text)


@router.post("/text-to-sign", response_model=SignSequenceResponse)
async def text_to_sign(body: TextToSignRequest):
    """Russian text → ordered avatar animation ids."""
    words = body.text.strip().split()
    ids: list[int] = []
    for word in words:
        idx = await vocabulary.lookup_by_text(word, body.language)
        ids.append(idx if idx is not None else 0)
    return SignSequenceResponse(avatar_animation_ids=ids)


# ── speech (Gemini multimodal — no separate STT key needed) ──────────────────

@router.post("/speech-to-text", response_model=TextResponse)
async def speech_to_text(audio: UploadFile = File(...)):
    """Recorded speech → literal Russian transcript (Gemini audio input)."""
    audio_bytes = await audio.read()
    if not audio_bytes:
        raise HTTPException(status_code=422, detail="audio is empty")
    try:
        text = await ai_voice_to_sign.transcribe(audio_bytes, audio.content_type or "audio/wav")
    except Exception as exc:
        logger.warning("speech_to_text failed: %s", exc)
        raise HTTPException(status_code=502, detail=f"Speech recognition failed: {exc}")
    return TextResponse(text=text)


@router.post("/ai/voice-to-sign", response_model=VoiceToSignResponse)
async def voice_to_sign(audio: UploadFile = File(...)):
    """Recorded speech → (recognized text, ordered sign-gesture word sequence).

    Single Gemini call: transcribes the whole sentence and glosses it into the
    known sign-asset vocabulary in one pass, so the avatar can play a
    meaningful gesture-by-gesture flow for the full sentence.
    """
    audio_bytes = await audio.read()
    if not audio_bytes:
        raise HTTPException(status_code=422, detail="audio is empty")
    try:
        text, words = await ai_voice_to_sign.transcribe_and_gloss(
            audio_bytes, audio.content_type or "audio/wav"
        )
    except Exception as exc:
        logger.warning("voice_to_sign failed: %s", exc)
        raise HTTPException(status_code=502, detail=f"Voice-to-sign failed: {exc}")
    return VoiceToSignResponse(text=text, words=words)


# ── AI-powered (Gemini, no dictionary) ───────────────────────────────────────

class GestureAIRequest(BaseModel):
    label: str                          # hint from on-device classifier
    landmarks: list[dict[str, Any]]     # 21 MediaPipe hand landmarks {x, y, z}


class SequenceAIRequest(BaseModel):
    labels: list[str]                   # sequence of captured gesture labels


@router.post("/ai/interpret-gesture", response_model=TextResponse)
async def ai_interpret_gesture(body: GestureAIRequest):
    """Single gesture + 21 landmarks → Gemini → Russian word (no dictionary)."""
    text = await ai_svc.interpret_gesture(body.label, body.landmarks)
    return TextResponse(text=text)


@router.post("/ai/interpret-sequence", response_model=TextResponse)
async def ai_interpret_sequence(body: SequenceAIRequest):
    """Sequence of gesture labels → Gemini → natural Russian sentence."""
    text = await ai_svc.interpret_sequence(body.labels)
    return TextResponse(text=text)


# ── Slovo RSL clip recognition (hukenovs/slovo MViTv2 video model) ────────────

class RecognizeClipRequest(BaseModel):
    frames: list[str]   # 32 base64-encoded JPEG frames captured around the sign


@router.post("/ai/recognize-clip", response_model=TextResponse)
async def recognize_clip(body: RecognizeClipRequest):
    """
    32 JPEG frames (base64) → Slovo MViTv2-small-32 ONNX → Russian RSL word.

    The Slovo model (hukenovs/slovo, CC-BY-SA 4.0) was trained on 1000 RSL
    signs from 194 signers; best accuracy ~64% on clean trimmed clips.

    Returns empty string on low confidence / duplicate so the client can show
    "повторите" instead of a wrong guess.
    Download model first: python scripts/download_slovo_model.py
    """
    from fastapi import HTTPException
    from app.integrations.slovo_client import SlovoClient

    if len(body.frames) < 1:
        raise HTTPException(status_code=422, detail="frames is empty")

    try:
        client = SlovoClient.get()
    except FileNotFoundError as e:
        raise HTTPException(status_code=503, detail=str(e))

    # Run CPU-bound ONNX inference off the event loop
    word = await asyncio.to_thread(client.predict, body.frames)
    return TextResponse(text=word or "")
