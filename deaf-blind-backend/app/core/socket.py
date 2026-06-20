"""Socket.IO ASGI app for live-class real-time relay (§1).

Mounted alongside FastAPI in main.py. Carries captions and translated text/labels
between teacher and student in real time. (Live video/WebRTC is a separate seam —
see services/live_class/signaling.py.)
"""
import socketio

from app.core.config import settings

sio = socketio.AsyncServer(
    async_mode="asgi",
    cors_allowed_origins="*" if settings.ENV != "prod" else [],
)

# ASGI app to mount at /socket.io in main.py
sio_app = socketio.ASGIApp(sio)
