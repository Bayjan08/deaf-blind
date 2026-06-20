"""Slovo RSL (Russian Sign Language) ONNX inference client.

Wraps hukenovs/slovo (third_party/slovo) — reuses its exact preprocessing
from demo.py and the 1000-class constants.py without modification.

Download the model first:
    python scripts/download_slovo_model.py

License: CC-BY-SA 4.0 (see third_party/slovo/license/)
"""
from __future__ import annotations

import base64
import logging
import os
import sys

import cv2
import numpy as np

logger = logging.getLogger(__name__)

# ── Paths ─────────────────────────────────────────────────────────────────────
_HERE = os.path.dirname(__file__)
SLOVO_DIR = os.path.abspath(os.path.join(_HERE, "../../third_party/slovo"))
MODEL_PATH = os.path.abspath(os.path.join(_HERE, "../../models/mvit32-2.onnx"))

# Inject slovo into sys.path so we can import its constants.py
if SLOVO_DIR not in sys.path:
    sys.path.insert(0, SLOVO_DIR)

from constants import classes as SLOVO_CLASSES  # noqa: E402 — must come after path setup

# ── Normalisation constants (from slovo config_example.yaml) ─────────────────
_MEAN = np.array([123.675, 116.28, 103.53], dtype=np.float32)
_STD  = np.array([58.395,  57.12,  57.375], dtype=np.float32)
_INPUT_SIZE  = 224
_WINDOW_SIZE = 32   # mvit32-2: 32-frame model
_NULL_TOKEN  = "---"


# ── Frame preprocessing (mirrors Runner.add_frame + Runner.resize from demo.py) ─
def _letterbox(img: np.ndarray, size: int = _INPUT_SIZE) -> np.ndarray:
    """Aspect-preserving resize + gray (114,114,114) padding — exact slovo logic."""
    h, w = img.shape[:2]
    r = size / max(h, w)
    new_w, new_h = int(round(w * r)), int(round(h * r))
    img = cv2.resize(img, (new_w, new_h), interpolation=cv2.INTER_LINEAR)
    pad_w = (size - new_w) / 2
    pad_h = (size - new_h) / 2
    top,    bottom = int(round(pad_h - 0.1)), int(round(pad_h + 0.1))
    left,   right  = int(round(pad_w - 0.1)), int(round(pad_w + 0.1))
    return cv2.copyMakeBorder(
        img, top, bottom, left, right,
        cv2.BORDER_CONSTANT, value=(114, 114, 114),
    )


def _preprocess_jpeg(b64_jpeg: str) -> np.ndarray:
    """Decode base64 JPEG → CHW float32 tensor, slovo normalisation.

    Returns shape [3, 224, 224].
    """
    raw = base64.b64decode(b64_jpeg)
    buf = np.frombuffer(raw, dtype=np.uint8)
    bgr = cv2.imdecode(buf, cv2.IMREAD_COLOR)
    if bgr is None:
        raise ValueError("Could not decode JPEG frame")
    rgb = cv2.cvtColor(bgr, cv2.COLOR_BGR2RGB)
    rgb = _letterbox(rgb, _INPUT_SIZE)
    rgb = (rgb.astype(np.float32) - _MEAN) / _STD
    return np.transpose(rgb, [2, 0, 1])   # HWC → CHW


# ── Singleton ONNX session ─────────────────────────────────────────────────────
class SlovoClient:
    """Singleton that holds the ONNX session for the lifetime of the process."""

    _instance: "SlovoClient | None" = None

    def __init__(self) -> None:
        import onnxruntime as ort

        if not os.path.exists(MODEL_PATH):
            raise FileNotFoundError(
                f"Slovo ONNX model not found at {MODEL_PATH}.\n"
                "Run:  python scripts/download_slovo_model.py"
            )

        ort.set_default_logger_severity(4)  # silence ort logs
        self._session = ort.InferenceSession(
            MODEL_PATH,
            providers=["CPUExecutionProvider"],
        )
        self._input_name = self._session.get_inputs()[0].name
        logger.info(
            "SlovoClient: loaded model %s  input=%s",
            MODEL_PATH,
            self._session.get_inputs()[0].shape,
        )
        self._last_word: str | None = None

    @classmethod
    def get(cls) -> "SlovoClient":
        if cls._instance is None:
            cls._instance = cls()
        return cls._instance

    def predict(self, frames_b64: list[str]) -> str | None:
        """
        Recognise an RSL sign from 32 base64-encoded JPEG frames.

        Returns the Russian word/letter, or None if null-token or duplicate
        of the last prediction (anti-spam).
        """
        if len(frames_b64) < _WINDOW_SIZE:
            logger.warning("predict: got %d frames, need %d", len(frames_b64), _WINDOW_SIZE)
            return None

        # Preprocess exactly like demo.py Runner.add_frame
        tensors = [_preprocess_jpeg(f) for f in frames_b64[:_WINDOW_SIZE]]

        # Stack: list of [3,224,224] → axis=1 → [3,32,224,224] → [None][None] → [1,1,3,32,224,224]
        input_tensor = np.stack(tensors, axis=1)[None][None].astype(np.float32)

        outputs = self._session.run(None, {self._input_name: input_tensor})[0]
        idx  = int(outputs.argmax())
        word = str(SLOVO_CLASSES.get(idx, _NULL_TOKEN))

        if word == _NULL_TOKEN:
            logger.debug("predict: null token — ignoring")
            return None

        if word == self._last_word:
            logger.debug("predict: same as last (%s) — anti-spam, ignoring", word)
            return None

        self._last_word = word
        logger.info("predict: RSL → %s", word)
        return word
