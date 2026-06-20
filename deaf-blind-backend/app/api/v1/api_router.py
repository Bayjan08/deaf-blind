"""API router aggregator — combines all v1 endpoint routers."""
from fastapi import APIRouter

from app.api.v1.endpoints import (
    academy,
    ai_controller,
    ai_translator,
    auth,
    health,
    live_class,
    music,
    pronunciation,
    translation,
    users,
    video_translation,
)

api_router = APIRouter()

api_router.include_router(health.router)
api_router.include_router(auth.router)
api_router.include_router(users.router)
api_router.include_router(translation.router)       # §1/§6/§7 shared engine
api_router.include_router(live_class.router)        # §1
api_router.include_router(academy.router)           # §2
api_router.include_router(music.router)             # §3
api_router.include_router(pronunciation.router)     # §4
api_router.include_router(ai_controller.router)     # §5
api_router.include_router(video_translation.router) # §6
api_router.include_router(ai_translator.router)     # §7
