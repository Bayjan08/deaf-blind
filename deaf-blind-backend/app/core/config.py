"""Application configuration — loaded from env vars or a local .env file.

Credentials are kept as separate fields (not a single DATABASE_URL string) so
passwords with special characters work without URL-encoding.
"""
import os

from pydantic_settings import BaseSettings, SettingsConfigDict

API_V1_PREFIX = "/api/v1"
VERSION = "0.1.0"

_PLACEHOLDER_DB_HOSTS = frozenset(
    {"", "YOUR_CLOUD_SQL_PUBLIC_IP", "your-cloud-sql-public-ip"}
)


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

    # --- Auth ---
    JWT_SECRET: str = "change-me-in-production"
    JWT_ALGORITHM: str = "HS256"

    # --- LiveKit (video meetings) ---
    LIVEKIT_URL: str = "ws://livekit:7880"           # server-side / Docker network
    LIVEKIT_PUBLIC_URL: str = "ws://localhost:7880"  # returned to mobile/web clients
    LIVEKIT_API_KEY: str = "devkey"
    LIVEKIT_API_SECRET: str = "secret"

    # --- Vertex AI / Gemini (same as cistech) ---
    # Gemini model — us-central1 has the widest model availability
    GEMINI_MODEL: str = "gemini-2.5-flash-lite"
    GCP_PROJECT_ID: str = "deaf-blind-500005"
    GCP_LOCATION: str = "us-central1"
    # Local dev: path to service account JSON file
    # On Cloud Run: leave empty — uses Application Default Credentials automatically
    VERTEX_SERVICE_ACCOUNT: str = ""

    # --- Other integrations ---
    GOOGLE_SPEECH_API_KEY: str = ""    # STT / TTS
    FIREBASE_CREDENTIALS_JSON: str = ""  # auth, storage, FCM

    # --- Vertex AI / GCP config ---
    GCP_PROJECT_ID: str = "deaf-blind-500005"
    GCP_LOCATION: str = "us-central1"
    VERTEX_SERVICE_ACCOUNT: str = "./credentials/deaf-blind-500005-b61d0c613dbf.json"
    GEMINI_MODEL: str = "gemini-2.5-flash"

    model_config = SettingsConfigDict(env_file=".env", extra="ignore")

    @property
    def on_cloud_run(self) -> bool:
        """Cloud Run automatically sets K_SERVICE; locally it's never set."""
        return bool(os.getenv("K_SERVICE"))

    @property
    def db_host_configured(self) -> bool:
        return self.DB_HOST not in _PLACEHOLDER_DB_HOSTS

    @property
    def use_cloud_sql_connector(self) -> bool:
        """Cloud Run always; locally when DB_HOST is unset and instance name is provided."""
        if self.on_cloud_run:
            return True
        if self.db_host_configured:
            return False
        return bool(self.CLOUD_SQL_CONNECTION_NAME)


settings = Settings()
