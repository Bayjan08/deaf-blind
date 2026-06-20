"""Deaf-Blind app backend — FastAPI entry point."""
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from config import settings

app = FastAPI(
    title="Deaf-Blind API",
    version="0.1.0",
    # Hide auto docs in production for safety; keep them on in dev.
    docs_url="/docs" if settings.ENV != "prod" else None,
)

# Allow the mobile app to call this API from any origin.
# Tighten allow_origins to your real app domains before a real launch.
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
def health():
    """Health check — Cloud Run and uptime monitors hit this."""
    return {"status": "healthy", "env": settings.ENV}


@app.get("/test_number_1")
def test():
    """Test endpoint — shows the deployment is working."""
    return {"message": "Backend deployed and running!", "env": settings.ENV, "version": "0.1.0"}


# ---- Add your real routes below ----
# Example:
# @app.post("/translate")
# def translate(...):
#     ...
