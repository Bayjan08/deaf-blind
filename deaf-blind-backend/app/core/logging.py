"""Logging configuration. Sets format/level and silences noisy third-party loggers."""
import logging

from app.core.config import settings

NOISY_LOGGERS = ["watchfiles.main", "sqlalchemy.engine.Engine", "urllib3.connectionpool"]


def setup_logging() -> None:
    """Configure root logging based on settings.LOG_LEVEL / DEBUG."""
    logging.basicConfig(
        level=logging.DEBUG if settings.DEBUG else settings.LOG_LEVEL,
        format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
    )
    for name in NOISY_LOGGERS:
        logging.getLogger(name).setLevel(logging.WARNING)
