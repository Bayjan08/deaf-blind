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
    },
}

# A simple 2-beat stress cue (stronger pulse on the stressed syllable). Reuses
# the same NotePattern shape the music-vibration feature uses on the client.
_STRESS_PATTERN: list[dict] = [
    {
        "name": "stressed",
        "colorHex": 0xFFEF5350,
        "vibrationHz": 200.0,
        "durationMs": 320,
        "intensity": 1.0,
    },
    {
        "name": "unstressed",
        "colorHex": 0xFF90A4AE,
        "vibrationHz": 120.0,
        "durationMs": 180,
        "intensity": 0.45,
    },
]

DEFAULT_VISEME = "AA"


def resolve(key: str) -> str:
    """Map a lesson path param (viseme id or phoneme) to a known viseme id."""
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
    return {
        "viseme": vid,
        "word": spec["word"],
        "phoneme": spec["phoneme"],
        "instructions": spec["instructions"],
        "target_metrics": spec["ranges"],
        "stress_pattern": _STRESS_PATTERN,
    }


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
