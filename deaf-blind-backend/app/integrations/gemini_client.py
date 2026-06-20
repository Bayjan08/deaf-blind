"""Vertex AI / Gemini client — mirrors cistech's production pattern.

Auth resolution (same as cistech vertex_auth.py):
  Local dev  → VERTEX_SERVICE_ACCOUNT points to credentials/vertex-service-account.json
  Cloud Run  → Application Default Credentials (ADC) from the attached service account
               No key file needed — GCP handles it automatically.

Usage:
    client = GeminiClient()
    text = await client.generate("Analyse this student's performance...",
                                  system_instruction="You are a helpful tutor.")
"""
from __future__ import annotations

import asyncio
import logging
import os
from typing import Optional

from app.core.config import settings

logger = logging.getLogger(__name__)


class GeminiClient:
    def __init__(self) -> None:
        import vertexai
        from vertexai.generative_models import GenerativeModel  # noqa: F401 (import check)

        credentials = _load_vertex_credentials()
        vertexai.init(
            project=settings.GCP_PROJECT_ID,
            location=settings.GCP_LOCATION,
            credentials=credentials,
        )
        self._model_name = settings.GEMINI_MODEL
        logger.info(
            "GeminiClient: Vertex AI | project=%s location=%s model=%s credentials=%s",
            settings.GCP_PROJECT_ID,
            settings.GCP_LOCATION,
            self._model_name,
            "service-account-file" if credentials else "ADC",
        )

    async def generate(self, prompt: str, system_instruction: Optional[str] = None) -> str:
        """Send a prompt to Gemini and return the text response."""
        return await self._generate([prompt], system_instruction)

    async def generate_with_audio(
        self,
        prompt: str,
        audio_bytes: bytes,
        mime_type: str,
        system_instruction: Optional[str] = None,
    ) -> str:
        """Send a prompt plus an inline audio clip to Gemini and return the text response."""
        from vertexai.generative_models import Part

        audio_part = Part.from_data(data=audio_bytes, mime_type=mime_type)
        return await self._generate([prompt, audio_part], system_instruction)

    async def _generate(self, parts: list, system_instruction: Optional[str] = None) -> str:
        from vertexai.generative_models import GenerationConfig, GenerativeModel

        model = (
            GenerativeModel(self._model_name, system_instruction=system_instruction)
            if system_instruction
            else GenerativeModel(self._model_name)
        )
        response = await asyncio.to_thread(
            model.generate_content,
            parts,
            generation_config=GenerationConfig(temperature=0.3),
        )
        try:
            return response.text or ""
        except ValueError:
            # Blocked by safety filter
            return ""


def _load_vertex_credentials():
    """Return explicit service-account credentials, or None to use ADC.

    Mirrors cistech's vertex_auth.load_vertex_credentials():
    - If VERTEX_SERVICE_ACCOUNT points to an existing file → load it.
    - Otherwise → return None so vertexai.init() falls back to ADC
      (which Cloud Run provides automatically via the attached service account).
    """
    cred_path = settings.VERTEX_SERVICE_ACCOUNT
    if not cred_path or not os.path.exists(cred_path):
        return None
    try:
        from google.oauth2 import service_account

        creds = service_account.Credentials.from_service_account_file(
            cred_path,
            scopes=["https://www.googleapis.com/auth/cloud-platform"],
        )
        logger.info("Vertex AI: loaded service-account key from %s", cred_path)
        return creds
    except Exception as exc:
        logger.warning("Failed to load Vertex credentials from %s: %s — falling back to ADC", cred_path, exc)
        return None
