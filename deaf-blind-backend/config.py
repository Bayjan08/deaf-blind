"""App configuration — loaded from env vars or a local .env file.

Credentials are kept as separate fields (not a single DATABASE_URL string) so
passwords with special characters like @ & ) } work without URL-encoding.
"""
import os

from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    ENV: str = "dev"
    PORT: int = 9000

    # --- Database credentials (used both locally and on Cloud Run) ---
    DB_USER: str = "postgres"
    DB_PASS: str = ""
    DB_NAME: str = "postgres"

    # --- Local dev only: connect directly to Cloud SQL public IP ---
    DB_HOST: str = ""          # e.g. 34.90.12.34
    DB_PORT: int = 5432

    # --- Cloud Run only: connect via the Cloud SQL connector (no public IP) ---
    CLOUD_SQL_CONNECTION_NAME: str = ""  # project:region:instance

    model_config = SettingsConfigDict(env_file=".env", extra="ignore")

    @property
    def on_cloud_run(self) -> bool:
        """Cloud Run automatically sets K_SERVICE; locally it's never set."""
        return bool(os.getenv("K_SERVICE"))


settings = Settings()
