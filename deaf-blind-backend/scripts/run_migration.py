#!/usr/bin/env python3
"""Apply SQL migrations without psql.

Usage (from deaf-blind-backend/):
  python3 -m venv .venv && source .venv/bin/activate
  pip install -r requirements.txt
  python scripts/run_migration.py

Or via Docker (uses .env from compose):
  docker compose exec backend python scripts/run_migration.py

Local DB access (pick one in .env):
  - DB_HOST=<Cloud SQL public IP>  (add your IP to Authorized networks)
  - CLOUD_SQL_CONNECTION_NAME=project:region:instance + `gcloud auth application-default login`
"""
from __future__ import annotations

import asyncio
import sys
from pathlib import Path

from sqlalchemy import text

# Ensure app package is importable when run as a script
BACKEND_ROOT = Path(__file__).resolve().parent.parent
if str(BACKEND_ROOT) not in sys.path:
    sys.path.insert(0, str(BACKEND_ROOT))


def _load_statements(path: Path) -> list[str]:
    raw = path.read_text(encoding="utf-8")
    statements: list[str] = []
    buffer: list[str] = []
    for line in raw.splitlines():
        stripped = line.strip()
        if not stripped or stripped.startswith("--"):
            continue
        buffer.append(line)
        if stripped.endswith(";"):
            statements.append("\n".join(buffer))
            buffer.clear()
    return statements


def _connection_target(settings) -> str:
    if settings.use_cloud_sql_connector:
        return f"Cloud SQL connector → {settings.CLOUD_SQL_CONNECTION_NAME}/{settings.DB_NAME}"
    return f"{settings.DB_HOST}:{settings.DB_PORT}/{settings.DB_NAME}"


async def run_migration(filename: str = "001_meetings.sql") -> None:
    from app.core.config import settings
    from app.db.connector import get_engine

    if not settings.db_host_configured and not settings.CLOUD_SQL_CONNECTION_NAME:
        print(
            "ERROR: Configure database access in deaf-blind-backend/.env:\n"
            "  • DB_HOST=<Cloud SQL public IP>, or\n"
            "  • CLOUD_SQL_CONNECTION_NAME=project:region:instance "
            "(then run `gcloud auth application-default login`)",
            file=sys.stderr,
        )
        sys.exit(1)

    sql_path = BACKEND_ROOT / "migrations" / filename
    if not sql_path.exists():
        print(f"ERROR: Migration file not found: {sql_path}", file=sys.stderr)
        sys.exit(1)

    statements = _load_statements(sql_path)
    engine = get_engine()

    print(f"Connecting to {_connection_target(settings)} …")
    async with engine.begin() as conn:
        for stmt in statements:
            await conn.execute(text(stmt))

    await engine.dispose()
    print(f"Applied {filename} successfully ({len(statements)} statements).")


if __name__ == "__main__":
    asyncio.run(run_migration())
