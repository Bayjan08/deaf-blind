# Deaf-Blind School — Educational Platform

An accessibility-first educational platform for deaf-blind students, combining live video classes, interactive learning games, haptic feedback, and AI-powered sign language translation.

---

## What This App Does

Deaf-Blind School addresses a critical gap in special education: most e-learning tools are built for sighted or hearing learners. This platform delivers structured lessons through **multiple sensory channels** — camera-based gesture recognition, vibration patterns, audio, and live video — so that students who are deaf, blind, or both can access interactive education.

Teachers can host live video classes from any device. Students progress through game-like modules covering the alphabet (via sign language gestures), music (via haptic vibration patterns), math, and pronunciation. An AI layer recognises hand gestures in real time and translates between sign language and Russian text.

---

## Features Implemented

### 1. Live Class (Video Meetings)
- Create a meeting room and share a 6-letter code with students
- Join a meeting by code or from a recent-meetings list
- Toggle camera and microphone independently
- Host can end the session for all participants
- Real-time participant list updated as people join/leave
- Automatic reconnect on network interruption
- Powered by **LiveKit** (WebRTC SFU)

### 2. Alphabet Game (Sign Language Academy)
- Step-by-step letter introduction screens (e.g. "Letter A")
- Practice screen: student shows the letter with their hand in front of the camera
- AI gesture matching gives pass/retry feedback in real time
- Graded exam at the end of each level
- Visual level map shows progress (locked → unlocked → completed nodes)
- Companion pet selected during onboarding accompanies the learner

### 3. Music Through Vibration
- Each musical note is mapped to a unique haptic vibration pattern
- Students feel the rhythm through the phone
- Note-recognition game: device vibrates a pattern and the student identifies the note
- Designed for learners who cannot hear audio feedback

### 4. Pronunciation Module
- Phoneme-based lessons with audio examples
- Microphone recording of the student's attempt
- Backend analyses the recording and returns feedback

### 5. AI Gesture Translator (Sign ↔ Text)
- Live camera screen with **MediaPipe Hands** running in a WebView
- 21 hand-joint landmarks visualised as cyan dots + skeleton overlay
- Hold a gesture for ~1.5 s → label is detected and sent to the backend
- **Sign-to-text**: gesture label sequence → Russian sentence (via Gemini)
- **Text-to-sign**: Russian input → avatar animation sequence played back on screen
- Built-in vocabulary (hello→Привет, yes→Да, no→Нет, and more)

### 6. Video Translation
- Upload a pre-recorded video
- Backend transcribes and translates the sign language content
- Async job model: submit → poll for result

### 7. AI Controller (Personalised Learning)
- Tracks student performance across all modules
- Generates personalised lesson recommendations via **Gemini 2.5 Flash Lite** (Vertex AI)
- Analytics dashboard for teachers (in progress)

### 8. User Profile & Auth
- Development JWT flow for local testing
- Firebase authentication (production, wired up but not yet enforced)
- Profile screen shows user details and overall progress

---

## How It Looks & Works

### Design System
| Token | Value |
|---|---|
| Primary purple | `#6C5CE7` |
| Accent orange | `#FF8A4C` |
| Success green | `#34C77B` |
| Dark background (live class) | `#0F0E1F` |
| Light background | `#F4F5FB` |
| Heading font | Baloo 2 (700) |
| Body font | Nunito (800) |

### Navigation Flow
```
App Launch
  └── Auth Gate
        ├── Dev token (local) / Firebase (prod)
        └── Main Shell
              ├── Home          → shortcuts to Subjects, Profile
              ├── Subjects Map  → Alphabet · Math · Music · Pronunciation
              │     ├── Alphabet  → Letter intro → Camera practice → Exam → Level map
              │     ├── Math      → Level map → Math intro → Practice → Success
              │     ├── Music     → Note list → Vibration recognition game
              │     └── Pronunciation → Phoneme lesson → Record → Feedback
              ├── Class         → Lobby (create / join) → Live video room
              └── Profile       → User info & progress
                    └── [FAB]   → Gesture Camera (sign ↔ text translator)
```

### Live Class Room
The meeting room occupies the full screen with a dark background (`#0F0E1F`). Remote video tiles fill the centre. A bottom control bar provides: mute microphone, toggle camera, and (for the host) an "End for all" button in red (`#FF3B5A`).

### Gesture Camera
Opens as a full-screen camera feed. A JavaScript MediaPipe bundle runs inside a `flutter_inappwebview` and draws the hand skeleton live. When a sign is held steady, the recognised label appears at the top and is queued for translation. A text field at the bottom accepts typed Russian for text-to-sign playback.

---

## Tech Stack

### Mobile (Flutter)
| Package | Purpose |
|---|---|
| Flutter 3.12 / Dart 3.12 | UI framework |
| flutter_riverpod 3.3.2 | Reactive state management |
| go_router 17.3.0 | Navigation & deep links |
| livekit_client 2.4.1 | WebRTC video conferencing |
| flutter_inappwebview 6.1.5 | MediaPipe hand tracking (JS in WebView) |
| camera 0.12.0 | Camera feed for gestures |
| vibration 3.2.0 | Haptic patterns for music |
| audioplayers 6.7.1 | Note audio playback |
| record 7.1.0 | Pronunciation recording |
| dio 5.9.2 | HTTP client |
| google_fonts 8.1.0 | Baloo 2 & Nunito |
| shared_preferences 2.5.3 | Local persistence |

### Backend (Python)
| Library | Purpose |
|---|---|
| FastAPI 0.115.6 | REST API framework |
| Uvicorn 0.34.0 | ASGI server |
| SQLAlchemy 2.0.36 (async) | ORM |
| PostgreSQL 16 | Relational database |
| Alembic 1.14.0 | Schema migrations |
| python-socketio 5.12.1 | Real-time relay for live class |
| livekit-api 0.8.2 | Room & token management |
| google-cloud-aiplatform 1.71.1 | Vertex AI / Gemini access |
| PyJWT 2.10.1 | JWT auth tokens |
| cloud-sql-python-connector | Cloud SQL (production) |

### Infrastructure
| Component | Role |
|---|---|
| Docker Compose | Local development stack |
| LiveKit Server | WebRTC SFU (video routing) |
| Google Cloud Run | Backend hosting |
| Google Cloud SQL | Managed PostgreSQL (production) |
| GitHub Actions | CI/CD — auto-deploy on push to `dev` / `main` |

---

## Project Structure

```
deaf-blind/
├── deaf-blind-mobile/              # Flutter app
│   ├── lib/
│   │   ├── main.dart
│   │   ├── app/                    # Root widget, auth gate
│   │   ├── config/                 # Routes (GoRouter), env vars
│   │   ├── core/
│   │   │   ├── haptics/            # Vibration service & note patterns
│   │   │   ├── network/            # Dio client & error handling
│   │   │   ├── theme/              # Colors & Material theme
│   │   │   ├── translation/        # Sign-to-text API wrappers
│   │   │   └── ml/                 # Gesture classifier, MediaPipe bridge
│   │   └── features/
│   │       ├── alphabet_game/      # §2 Letters, pets, exams
│   │       ├── music_vibration/    # §3 Haptic music
│   │       ├── live_class/         # §1 LiveKit video meetings
│   │       ├── ai_translator/      # §7 Gesture camera
│   │       ├── pronunciation/      # §4 Speech lessons
│   │       ├── video_translation/  # §6 Async video upload
│   │       ├── ai_controller/      # §5 Recommendations
│   │       └── deaf_school/        # Main shell, bottom nav, overlays
│   └── assets/
│       ├── images/                 # Pet sprites, UI art
│       └── html/
│           └── hand_tracker.html   # MediaPipe JS (runs in WebView)
│
├── deaf-blind-backend/             # FastAPI backend
│   ├── app/
│   │   ├── api/v1/endpoints/       # REST endpoints (auth, meetings, academy…)
│   │   ├── core/                   # Config, security, Socket.IO, lifespan
│   │   ├── db/                     # SQLAlchemy session, engine, base
│   │   ├── models/                 # ORM models (meetings, levels, pets…)
│   │   ├── schemas/                # Pydantic request/response models
│   │   └── services/               # Business logic per feature
│   ├── alembic/                    # Migration config
│   ├── migrations/                 # Migration scripts
│   ├── Dockerfile
│   └── requirements.txt
│
├── docs/
│   └── VIDEO_MEETINGS.md           # LiveKit setup & two-device testing guide
├── docker-compose.yml              # Local: Postgres · LiveKit · Backend
└── .github/workflows/
    └── deploy-backend.yml          # Auto-deploy to Cloud Run on push
```

---

## Local Development

### Prerequisites
- Docker & Docker Compose
- Flutter SDK 3.12+
- Android Studio / Xcode (for mobile emulator)

### 1. Start the backend stack

```bash
cp deaf-blind-backend/.env.example deaf-blind-backend/.env
# Defaults work for local dev; fill in JWT_SECRET with any random string

docker compose up --build
# Postgres  → localhost:5433
# LiveKit   → localhost:7880
# Backend   → localhost:9000
```

### 2. Run database migrations

```bash
cd deaf-blind-backend
python scripts/run_migration.py
```

### 3. Get a dev JWT token

```bash
curl -X POST http://localhost:9000/api/v1/auth/dev-token \
  -H "Content-Type: application/json" \
  -d '{"user_id": "user1", "display_name": "Test User"}'
```

### 4. Run the Flutter app

```bash
cd deaf-blind-mobile
flutter pub get
flutter run
```

The app reads `BACKEND_URL` and `LIVEKIT_URL` from `lib/config/env.dart`. Update these to your machine's local IP address when running on a physical device.

---

## Cloud Deployment (Google Cloud Run)

| Branch | Cloud Run service |
|---|---|
| `dev` | `deaf-blind-api-dev` |
| `main` | `deaf-blind-api-prod` |

The GitHub Actions workflow (`.github/workflows/deploy-backend.yml`) builds the Docker image, pushes it to Artifact Registry, and deploys to Cloud Run automatically on every push.

Production environment uses:
- **Cloud SQL** (PostgreSQL 16) via the async Cloud SQL connector
- **Vertex AI** via Application Default Credentials (no service-account key file needed on Cloud Run)
- **LiveKit Cloud** or a self-hosted LiveKit instance

---

## Environment Variables

| Variable | Example | Description |
|---|---|---|
| `ENV` | `dev` | `dev` or `prod` |
| `DB_USER` | `postgres` | Database user |
| `DB_PASS` | `postgres` | Database password |
| `DB_NAME` | `deaf_blind` | Database name |
| `DB_HOST` | `localhost` | Database host |
| `LIVEKIT_URL` | `ws://livekit:7880` | Internal LiveKit WS URL |
| `LIVEKIT_PUBLIC_URL` | `ws://127.0.0.1:7880` | Client-facing LiveKit URL |
| `LIVEKIT_API_KEY` | `devkey` | LiveKit API key |
| `LIVEKIT_API_SECRET` | `secret` | LiveKit API secret |
| `JWT_SECRET` | `change-in-prod` | JWT signing secret |
| `GCP_PROJECT_ID` | `deaf-blind-500005` | Google Cloud project |
| `VERTEX_SERVICE_ACCOUNT` | `./credentials/….json` | SA key (local only) |

---

## API Overview

| Method | Path | Description |
|---|---|---|
| `POST` | `/api/v1/auth/dev-token` | Issue dev JWT |
| `POST` | `/api/v1/meetings/create` | Create meeting room |
| `POST` | `/api/v1/meetings/join` | Join by ID or code |
| `POST` | `/api/v1/meetings/leave` | Leave gracefully |
| `POST` | `/api/v1/meetings/end` | Host ends meeting for all |
| `GET` | `/api/v1/meetings/recent` | Recent meetings for user |
| `GET` | `/api/v1/academy/levels` | Alphabet game levels |
| `POST` | `/api/v1/academy/gesture-check` | Validate gesture attempt |
| `POST` | `/api/v1/academy/exam/{level_id}/grade` | Grade exam |
| `GET` | `/api/v1/music/notes` | Music note list |
| `POST` | `/api/v1/music/game/answer` | Submit note answer |
| `POST` | `/api/v1/translation/sign-to-text` | Gesture labels → Russian text |
| `POST` | `/api/v1/translation/text-to-sign` | Russian text → avatar animation IDs |
| `POST` | `/api/v1/video-translation/jobs` | Submit video for translation |
| `GET` | `/api/v1/video-translation/jobs/{id}` | Poll job status |
| `GET` | `/api/v1/health` | Health check |

Full LiveKit setup and two-device testing instructions are in [`docs/VIDEO_MEETINGS.md`](docs/VIDEO_MEETINGS.md).
