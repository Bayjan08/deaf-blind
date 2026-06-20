-- Video meeting tables (LiveKit-backed)
-- Run once against your Postgres database:
--   psql "$DATABASE_URL" -f migrations/001_meetings.sql

CREATE TABLE IF NOT EXISTS meetings (
    id VARCHAR(36) PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    host_id VARCHAR(128) NOT NULL,
    code VARCHAR(8) NOT NULL UNIQUE,
    status VARCHAR(20) NOT NULL DEFAULT 'active',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    ended_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS ix_meetings_host_id ON meetings (host_id);
CREATE INDEX IF NOT EXISTS ix_meetings_code ON meetings (code);

CREATE TABLE IF NOT EXISTS meeting_participants (
    id SERIAL PRIMARY KEY,
    user_id VARCHAR(128) NOT NULL,
    meeting_id VARCHAR(36) NOT NULL REFERENCES meetings (id) ON DELETE CASCADE,
    display_name VARCHAR(120) NOT NULL DEFAULT 'Guest',
    joined_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    left_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS ix_meeting_participants_user_id ON meeting_participants (user_id);
CREATE INDEX IF NOT EXISTS ix_meeting_participants_meeting_id ON meeting_participants (meeting_id);
