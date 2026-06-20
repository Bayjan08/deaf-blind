"""§4 Viseme definitions + geometric scoring.

Single source of truth for the camera mouth-shape feature. A *viseme* is a
visually-distinct mouth shape group. Many phonemes collapse into one viseme
(/p/,/b/,/m/ are identical on camera), so lessons target visemes and feedback
is **directional** — we never claim a precision accuracy %.

All metric values are normalized by interocular distance (eye-corner span) on
the device so they are scale-invariant. `score()` returns directional cues plus
a coarse 0..1 score kept only for internal progress tracking.
"""
from __future__ import annotations

# Per-metric directional cues: (cue when value is BELOW range, cue when ABOVE).
_CUES: dict[str, tuple[str, str]] = {
    "lipGap": ("Open your mouth a little wider", "Close your mouth a little"),
    "mouthWidth": (
        "Spread your lips wider, like a small smile",
        "Bring your lip corners inward",
    ),
    "rounding": (
        "Round your lips more — make them small and circular",
        "Spread your lips wider, like a smile",
    ),
    "jawOpen": ("Drop your jaw more", "Relax your jaw a little"),
    "lipClosure": ("Press your lips together", "Part your lips a little"),
}

# viseme id -> definition. `ranges` maps metric -> [min, max] (normalized).
# `stress_pattern` is a distinct haptic "feel" per viseme group (the only
# blind-accessible cue) — reuses the music-vibration feature's NotePattern
# shape. Letters that share a viseme also share its rhythm, matching how the
# mouth-shape score already treats them as the same target.
VISEMES: dict[str, dict] = {
    "PBM": {
        "word": "mama",
        "phoneme": "/m/",
        "instructions": "Press both lips together, then release.",
        "ranges": {
            "lipGap": [0.0, 0.06],
            "lipClosure": [0.7, 1.0],
            "mouthWidth": [0.38, 0.62],
        },
        # Press-release, press-release — two equal short pulses.
        "stress_pattern": [
            {"name": "press", "colorHex": 0xFFEF5350, "vibrationHz": 160.0, "durationMs": 160, "intensity": 0.85},
            {"name": "press", "colorHex": 0xFFEF5350, "vibrationHz": 160.0, "durationMs": 160, "intensity": 0.85},
        ],
    },
    "AA": {
        "word": "ah",
        "phoneme": "/a/",
        "instructions": "Open wide and drop your jaw, like at the doctor's.",
        "ranges": {
            "lipGap": [0.22, 0.6],
            "jawOpen": [0.5, 1.0],
            "mouthWidth": [0.4, 0.66],
        },
        # One long, strong, sustained pulse — open and held.
        "stress_pattern": [
            {"name": "open", "colorHex": 0xFFFF7043, "vibrationHz": 130.0, "durationMs": 550, "intensity": 1.0},
        ],
    },
    "EE": {
        "word": "see",
        "phoneme": "/i/",
        "instructions": "Spread your lips wide like a smile, teeth close.",
        "ranges": {
            "lipGap": [0.04, 0.18],
            "mouthWidth": [0.6, 0.92],
            "rounding": [1.5, 6.0],
        },
        # One short, bright, high-frequency pulse.
        "stress_pattern": [
            {"name": "bright", "colorHex": 0xFF42A5F5, "vibrationHz": 220.0, "durationMs": 140, "intensity": 0.9},
        ],
    },
    "OW": {
        "word": "you",
        "phoneme": "/u/",
        "instructions": "Push your lips forward into a small round shape.",
        "ranges": {
            "lipGap": [0.08, 0.28],
            "mouthWidth": [0.26, 0.46],
            "rounding": [0.0, 1.2],
        },
        # One medium, lower-frequency "round" pulse.
        "stress_pattern": [
            {"name": "round", "colorHex": 0xFF66BB6A, "vibrationHz": 90.0, "durationMs": 320, "intensity": 0.65},
        ],
    },
    "FV": {
        "word": "five",
        "phoneme": "/f/",
        "instructions": "Touch your top teeth gently to your lower lip.",
        "ranges": {
            "lipGap": [0.02, 0.12],
            "mouthWidth": [0.42, 0.66],
            "lipClosure": [0.3, 0.7],
        },
        # Three quick, light flutters — airflow texture.
        "stress_pattern": [
            {"name": "flutter", "colorHex": 0xFFAB47BC, "vibrationHz": 240.0, "durationMs": 70, "intensity": 0.4},
            {"name": "flutter", "colorHex": 0xFFAB47BC, "vibrationHz": 240.0, "durationMs": 70, "intensity": 0.4},
            {"name": "flutter", "colorHex": 0xFFAB47BC, "vibrationHz": 240.0, "durationMs": 70, "intensity": 0.4},
        ],
    },
}

DEFAULT_VISEME = "AA"

# v1 scope: single Russian letters -> their viseme group (visually-distinct
# mouth shape). Many letters share a shape, which is expected.
LETTER_VISEMES: dict[str, str] = {
    "А": "AA",
    "О": "OW",
    "У": "OW",
    "И": "EE",
    "Ы": "EE",
    "Э": "AA",
    "М": "PBM",
    "Б": "PBM",
    "П": "PBM",
    "Ф": "FV",
    "В": "FV",
}


def resolve(key: str) -> str:
    """Map a lesson path param (letter, viseme id or phoneme) to a viseme id."""
    if key in LETTER_VISEMES:
        return LETTER_VISEMES[key]
    if key in VISEMES:
        return key
    upper = key.upper()
    if upper in VISEMES:
        return upper
    for vid, spec in VISEMES.items():
        if spec["phoneme"].strip("/") == key.strip("/"):
            return vid
    return DEFAULT_VISEME


def lesson(key: str) -> dict:
    """Lesson payload for the client: target ranges, copy and the haptic cue."""
    vid = resolve(key)
    spec = VISEMES[vid]
    is_letter = key in LETTER_VISEMES
    return {
        "viseme": vid,
        "letter": key if is_letter else None,
        # For a letter lesson, show the letter itself; otherwise the example word.
        "word": key if is_letter else spec["word"],
        "phoneme": spec["phoneme"],
        "instructions": spec["instructions"],
        "target_metrics": spec["ranges"],
        "stress_pattern": spec["stress_pattern"],
    }


def letters() -> list[dict]:
    """The catalogue of practiceable letters (v1 alphabet scope)."""
    return [
        {"letter": ltr, "viseme": vid, "example": VISEMES[vid]["word"]}
        for ltr, vid in LETTER_VISEMES.items()
    ]


def score(target_viseme: str, metrics: dict[str, float]) -> dict:
    """Compare measured mouth metrics to the target viseme's ranges.

    Returns {feedback_text, cues, coarse_score}. Directional only — the score is
    internal and not meant to be shown as a precise percentage.
    """
    vid = resolve(target_viseme)
    ranges: dict[str, list[float]] = VISEMES[vid]["ranges"]

    scored: list[tuple[float, str]] = []  # (distance, cue) for out-of-range metrics
    closeness: list[float] = []

    for metric, (lo, hi) in ranges.items():
        value = metrics.get(metric)
        if value is None:
            continue
        width = max(hi - lo, 1e-6)
        if value < lo:
            dist = (lo - value) / width
            scored.append((dist, _CUES[metric][0]))
            closeness.append(max(0.0, 1.0 - dist))
        elif value > hi:
            dist = (value - hi) / width
            scored.append((dist, _CUES[metric][1]))
            closeness.append(max(0.0, 1.0 - dist))
        else:
            closeness.append(1.0)

    coarse = sum(closeness) / len(closeness) if closeness else 0.0

    # Surface at most the two worst metrics as cues, so it never overwhelms.
    scored.sort(key=lambda t: t[0], reverse=True)
    cues = [cue for _, cue in scored[:2]]

    if not cues:
        feedback = "Nicely done — that's very close to the right shape!"
    elif coarse >= 0.6:
        feedback = "Close! Small adjustment:"
    else:
        feedback = "Good try — let's adjust:"

    return {"feedback_text": feedback, "cues": cues, "coarse_score": round(coarse, 3)}
