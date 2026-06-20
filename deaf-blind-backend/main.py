"""Deaf / Hard-of-Hearing School API — FastAPI entry point.

Layered architecture (mirrors CarsBackend):
  app/api      — routers
  app/core     — config, lifespan, middleware, socket.io
  app/db       — engine/session
  app/integrations, app/models, app/schemas, app/services, app/tasks, app/utils
"""
from pathlib import Path

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles

from app.api.v1.api_router import api_router
from app.api.v1.endpoints import health
from app.core.config import API_V1_PREFIX, VERSION, settings
from app.core.lifespan import lifespan
from app.core.logging import setup_logging
from app.core.socket import sio_app
from app.core import socket_events  # noqa: F401  (registers live-class handlers)

setup_logging()

app = FastAPI(
    title="Deaf-Blind School API",
    version=VERSION,
    lifespan=lifespan,
    docs_url="/docs" if settings.ENV != "prod" else None,
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # tighten before real launch
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Liveness probe — no /api/v1 prefix (Docker, load balancers, README)
app.include_router(health.router)

# All other REST endpoints live under /api/v1
app.include_router(api_router, prefix=API_V1_PREFIX)

# Stored pronunciation audio clips (§4) — local media dir (swap for GCS in prod).
_media_dir = Path("media")
_media_dir.mkdir(parents=True, exist_ok=True)
app.mount("/media", StaticFiles(directory=str(_media_dir)), name="media")

# Real-time live-class relay (§1)
app.mount("/socket.io", sio_app)


@app.get("/")
def root():
    return {"service": "deaf-blind-school-api", "env": settings.ENV, "status": "ok"}
