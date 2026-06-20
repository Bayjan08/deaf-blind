"""Application lifespan — startup/shutdown hooks.

Startup: validate config, init DB pool, init Firebase, load fixed vocabulary.
Shutdown: dispose DB engine, close integration clients.
"""
import logging
from contextlib import asynccontextmanager

from fastapi import FastAPI

from app.core.config import settings

logger = logging.getLogger(__name__)


@asynccontextmanager
async def lifespan(app: FastAPI):
    logger.info("Startup — env=%s port=%s", settings.ENV, settings.PORT)
    # TODO: init_firebase(), warm vocabulary cache, etc.
    yield
    logger.info("Shutdown")
    # TODO: dispose engine, close clients.
