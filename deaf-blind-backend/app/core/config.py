"""Application configuration — loaded from env vars or a local .env file.

Credentials are kept as separate fields (not a single DATABASE_URL string) so
passwords with special characters work without URL-encoding.
"""
import os

from pydantic_settings import BaseSettings, SettingsConfigDict

API_V1_PREFIX = "/api/v1"
VERSION = "0.1.0"


class Settings(BaseSettings):
    ENV: str = "dev"
    PORT: int = 9000
    DEBUG: bool = True
    LOG_LEVEL: str = "INFO"

    # --- Database credentials ---
    DB_USER: str = "postgres"
    DB_PASS: str = ""
    DB_NAME: str = "postgres"
    DB_HOST: str = ""          # local dev: Cloud SQL public IP
    DB_PORT: int = 5432
    CLOUD_SQL_CONNECTION_NAME: str = ""  # Cloud Run only: project:region:instance

    # --- Integrations (stubs; fill when implementing) ---
    GEMINI_API_KEY: str = ""           # §5 AI controller, translation assist
    GOOGLE_SPEECH_API_KEY: str = ""    # STT / TTS
    FIREBASE_CREDENTIALS_JSON: str = ""  # auth, storage, FCM

    model_config = SettingsConfigDict(env_file=".env", extra="ignore")

    @property
    def on_cloud_run(self) -> bool:
        """Cloud Run automatically sets K_SERVICE; locally it's never set."""
        return bool(os.getenv("K_SERVICE"))


settings = Settings()
