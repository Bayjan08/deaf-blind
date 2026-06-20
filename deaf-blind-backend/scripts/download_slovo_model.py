#!/usr/bin/env python3
"""Download the Slovo MViTv2-small-32 ONNX model (140 MB) into models/.

Run once before starting the backend locally:
    python scripts/download_slovo_model.py
"""
import os
import urllib.request

MODEL_URL = (
    "https://rndml-team-cv.obs.ru-moscow-1.hc.sbercloud.ru"
    "/datasets/slovo/models/mvit/onnx/mvit32-2.onnx"
)
OUT_PATH = os.path.join(os.path.dirname(__file__), "..", "models", "mvit32-2.onnx")


def _progress(count, block, total):
    pct = count * block / total * 100
    bar = "#" * int(pct / 2)
    print(f"\r[{bar:<50}] {pct:5.1f}%", end="", flush=True)


def main():
    out = os.path.abspath(OUT_PATH)
    if os.path.exists(out):
        size_mb = os.path.getsize(out) / 1024 / 1024
        print(f"✅  Model already exists: {out}  ({size_mb:.1f} MB)")
        return

    os.makedirs(os.path.dirname(out), exist_ok=True)
    print(f"⬇  Downloading Slovo MViTv2-small-32 (~140 MB) …\n   {MODEL_URL}")
    urllib.request.urlretrieve(MODEL_URL, out, reporthook=_progress)
    print(f"\n✅  Saved to: {out}")


if __name__ == "__main__":
    main()
