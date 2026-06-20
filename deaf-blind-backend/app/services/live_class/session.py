"""§1 Live-class session lifecycle: create / join / leave, participant state."""


async def create_session(teacher_id: int) -> dict:
    """Create a ClassSession, return {session_id, room_code}. Stub."""
    raise NotImplementedError


async def join_session(room_code: str, user_id: int) -> dict:
    raise NotImplementedError
