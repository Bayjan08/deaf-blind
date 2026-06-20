# Video Meetings (LiveKit)

Production-ready video conferencing for the Deaf-Blind School app. The **Класс** tab opens a lobby first; video starts only after **Начать урок** or **Войти в класс**.

## Architecture

| Layer | Tech |
|-------|------|
| Mobile | Flutter + `livekit_client` + Riverpod |
| Backend | FastAPI + PostgreSQL + LiveKit token API |
| SFU | LiveKit Server (Docker) |
| Auth | JWT (`POST /api/v1/auth/dev-token` in dev) |

### Mobile feature layout (`lib/features/live_class/`)

```
live_class.dart              # barrel — import this from other features
domain/models/               # Meeting, MeetingConnection, MeetingRoomPhase
data/
  datasources/               # REST API
  repositories/              # repository pattern
  cache/                     # recent meetings (SharedPreferences)
  livekit/                   # room controller + event listener
  mappers/                   # error mapping
presentation/
  providers/                 # Riverpod
  screens/                   # lobby + room (thin orchestrators)
  widgets/lobby/             # lobby UI pieces
  widgets/room/              # in-call UI pieces
```

### Backend services (`app/services/meetings/`)

```
livekit_client.py   # token + room create/delete
meeting_repo.py     # DB queries
service.py          # orchestration (create/join/leave/end)
```

## API (all require `Authorization: Bearer <jwt>`)

| Method | Path | Description |
|--------|------|-------------|
| POST | `/api/v1/meetings/create` | Create meeting, return LiveKit token |
| POST | `/api/v1/meetings/join` | Join by `meeting_id` or `code` |
| POST | `/api/v1/meetings/leave` | Leave meeting |
| POST | `/api/v1/meetings/end` | Host ends meeting for everyone |
| GET | `/api/v1/meetings/{id}` | Meeting details |
| GET | `/api/v1/meetings/recent` | Recent meetings for user |
| POST | `/api/v1/auth/dev-token` | Dev JWT (disabled when `ENV=prod`) |

Interactive docs: http://localhost:9000/docs

## Database

**Option A — Python script (no `psql` required):**

```bash
cd deaf-blind-backend
python3 -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
python scripts/run_migration.py
```

Or if Docker is already running:

```bash
docker compose exec backend python scripts/run_migration.py
```

**Option B — `psql` (install once: `brew install libpq` then `brew link --force libpq`):**

```bash
psql "postgresql://USER:PASS@HOST:5432/DB" -f deaf-blind-backend/migrations/001_meetings.sql
```

Before running either option, set `DB_HOST` in `deaf-blind-backend/.env` to your real Cloud SQL public IP (not the placeholder).

Tables: `meetings`, `meeting_participants`.

## Local setup

### 1. Environment

Copy and edit backend env:

```bash
cp deaf-blind-backend/.env.example deaf-blind-backend/.env
```

Ensure these values exist:

```env
JWT_SECRET=local-dev-jwt-secret
LIVEKIT_URL=ws://livekit:7880
LIVEKIT_PUBLIC_URL=ws://localhost:7880
LIVEKIT_API_KEY=devkey
LIVEKIT_API_SECRET=secret
```

For **Android emulator**, set `LIVEKIT_PUBLIC_URL=ws://10.0.2.2:7880` or pass `--dart-define=LIVEKIT_URL=ws://10.0.2.2:7880` on the Flutter side.

### 2. Start infrastructure

```bash
docker compose up --build
```

This starts **LiveKit** (port 7880) and the **backend** (port 9000).

### 3. Run migration

Apply `001_meetings.sql` to your Postgres database (same credentials as in `.env`).

### 4. Flutter app

```bash
cd deaf-blind-mobile
flutter pub get
```

**Client A — Android emulator (host):**

```bash
flutter run \
  --dart-define=BACKEND_URL=http://10.0.2.2:9000 \
  --dart-define=LIVEKIT_URL=ws://10.0.2.2:7880 \
  --dart-define=USER_ID=teacher-1 \
  --dart-define=USER_NAME=Teacher
```

**Client B — second device / iOS sim / Flutter Web:**

```bash
flutter run -d chrome \
  --dart-define=BACKEND_URL=http://localhost:9000 \
  --dart-define=LIVEKIT_URL=ws://localhost:7880 \
  --dart-define=USER_ID=student-1 \
  --dart-define=USER_NAME=Student
```

Enable web once if needed: `flutter create . --platforms=web`

## Testing with two clients

1. Open **Класс** tab on Client A — lobby appears (no camera yet).
2. Tap **Начать урок** — Client A enters the room; note the **6-letter code** in the header.
3. On Client B, open **Класс** → enter code → **Войти в класс**.
4. Verify:
   - Both see each other's video
   - Audio works both ways
   - Mute / camera / leave / rejoin
   - Host can **End meeting** (orange stop icon)

## Error handling

| Case | UX |
|------|-----|
| Camera/mic denied | Russian error message, return to lobby |
| Invalid code | «Неверный код встречи» |
| Meeting ended | «Встреча уже завершена» |
| Network loss | LiveKit reconnect UI («Переподключение…») |

## Security notes

- LiveKit tokens are generated **only on the backend**.
- JWT protects all meeting endpoints.
- Replace `POST /auth/dev-token` with Firebase login before production.
- Set strong `JWT_SECRET` and real LiveKit keys in production.
