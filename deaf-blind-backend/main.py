"""Deaf-Blind app backend — FastAPI entry point."""
from contextlib import asynccontextmanager

from fastapi import FastAPI, Depends
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import text

from config import settings
from database import get_db


@asynccontextmanager
async def lifespan(app: FastAPI):
    print(f"Starting up — env={settings.ENV}, port={settings.PORT}")
    yield
    print("Shutting down")


app = FastAPI(
    title="Deaf-Blind API",
    version="0.1.0",
    lifespan=lifespan,
    docs_url="/docs" if settings.ENV != "prod" else None,
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/")
def root():
    return {"service": "deaf-blind-api", "env": settings.ENV, "status": "ok"}


@app.get("/health")
async def health(db: AsyncSession = Depends(get_db)):
    """Health check — also verifies DB connection."""
    try:
        await db.execute(text("SELECT 1"))
        db_status = "connected"
    except Exception as e:
        db_status = f"error: {e}"
    return {"status": "healthy", "env": settings.ENV, "db": db_status}


# ---- Add your real routes below ----
