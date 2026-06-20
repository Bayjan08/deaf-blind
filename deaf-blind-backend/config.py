"""App configuration — loaded from env vars or .env file locally."""
import os

from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    ENV: str = os.getenv("ENV", "dev")
    PORT: int = int(os.getenv("PORT", "9000"))

    # --- Database ---
    # Local: postgres://user:pass@host:5432/dbname  (direct TCP to Cloud SQL)
    # Cloud Run: leave empty — connector uses CLOUD_SQL_CONNECTION_NAME instead
    DATABASE_URL: str = os.getenv("DATABASE_URL", "")

    # Cloud SQL instance connection name: project:region:instance
    # e.g. deaf-blind-500005:europe-west1:deaf-blind-db-dev
    CLOUD_SQL_CONNECTION_NAME: str = os.getenv("CLOUD_SQL_CONNECTION_NAME", "")

    DB_USER: str = os.getenv("DB_USER", "postgres")
    DB_PASS: str = os.getenv("DB_PASS", "")
    DB_NAME: str = os.getenv("DB_NAME", "deafblind")

    class Config:
        env_file = ".env"


settings = Settings()
