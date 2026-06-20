"""App configuration, loaded from environment variables.

Locally these come from a .env file. On Cloud Run they come from the
service's env vars / secrets — so dev and prod can differ without code changes.
"""
import os

from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    # "dev" or "prod" — controls docs visibility and any env-specific behavior.
    ENV: str = os.getenv("ENV", "dev")

    # Cloud Run injects PORT; default 8080 for local runs.
    PORT: int = int(os.getenv("PORT", "8080"))

    # Add your own settings here, e.g.:
    # DATABASE_URL: str = ""
    # OPENAI_API_KEY: str = ""

    class Config:
        env_file = ".env"


settings = Settings()
