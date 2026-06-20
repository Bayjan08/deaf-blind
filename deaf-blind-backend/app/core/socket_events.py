"""Live-class Socket.IO event handlers (§1).

Events (relay only — translation happens in services/live_class + translation_engine):
- join_session   : participant joins a class room
- leave_session  : participant leaves
- caption        : teacher speech-to-text caption -> broadcast to student
- sign_label     : student recognized gesture label -> translated -> broadcast to teacher
"""
from app.core.socket import sio


@sio.event
async def connect(sid, environ):  # noqa: D401
    ...


@sio.event
async def disconnect(sid):
    ...


@sio.on("join_session")
async def join_session(sid, data: dict):
    """data = {session_id, role}. Adds sid to the room."""
    raise NotImplementedError


@sio.on("caption")
async def caption(sid, data: dict):
    """Teacher -> student: relay live caption text. data = {session_id, text}."""
    raise NotImplementedError


@sio.on("sign_label")
async def sign_label(sid, data: dict):
    """Student -> teacher: relay recognized gesture label as text/speech."""
    raise NotImplementedError
