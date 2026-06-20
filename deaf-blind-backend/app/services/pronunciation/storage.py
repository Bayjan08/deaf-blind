"""§4 Audio clip storage for pronunciation attempts.

v1 saves clips to a local media directory and returns a served URL path. On
Cloud Run the filesystem is ephemeral, so swap `_save_bytes` for GCS/Firebase
Storage before relying on this in production (the call sites won't change).
"""
from __future__ import annotations

import uuid
from pathlib import Path

MEDIA_ROOT = Path("media")
_SUBDIR = "pronunciation"
MEDIA_URL_PREFIX = "/media"


def save_audio(student_id: str, filename: str | None, data: bytes) -> str | None:
    """Persist an uploaded audio clip and return its served URL path."""
    if not data:
        return None
    suffix = Path(filename or "clip.wav").suffix or ".wav"
    name = f"{student_id}_{uuid.uuid4().hex}{suffix}"
    return _save_bytes(data, name)


def _save_bytes(data: bytes, name: str) -> str:
    target_dir = MEDIA_ROOT / _SUBDIR
    target_dir.mkdir(parents=True, exist_ok=True)
    (target_dir / name).write_bytes(data)
    return f"{MEDIA_URL_PREFIX}/{_SUBDIR}/{name}"
