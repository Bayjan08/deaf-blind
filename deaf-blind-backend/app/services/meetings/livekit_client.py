"""LiveKit room and token helpers."""
import logging

from livekit import api

from app.core.config import settings

logger = logging.getLogger(__name__)


def _http_url() -> str:
    return settings.LIVEKIT_URL.replace("ws://", "http://").replace("wss://", "https://")


def create_livekit_token(
    *,
    room_name: str,
    identity: str,
    display_name: str,
    is_host: bool,
) -> str:
    """Generate a LiveKit access token — backend only."""
    grants = api.VideoGrants(
        room_join=True,
        room=room_name,
        can_publish=True,
        can_subscribe=True,
        can_publish_data=True,
    )
    if is_host:
        grants.room_admin = True

    return (
        api.AccessToken(settings.LIVEKIT_API_KEY, settings.LIVEKIT_API_SECRET)
        .with_identity(identity)
        .with_name(display_name)
        .with_grants(grants)
        .to_jwt()
    )


async def create_livekit_room(room_name: str) -> None:
    """Ensure a LiveKit room exists (no-op if unreachable — LiveKit auto-creates on join)."""
    try:
        lk = api.LiveKitAPI(_http_url(), settings.LIVEKIT_API_KEY, settings.LIVEKIT_API_SECRET)
        await lk.room.create_room(api.CreateRoomRequest(name=room_name))
        await lk.aclose()
    except Exception as exc:  # noqa: BLE001
        logger.debug("LiveKit create_room skipped: %s", exc)


async def delete_livekit_room(room_name: str) -> None:
    """Disconnect all participants by deleting the LiveKit room."""
    try:
        lk = api.LiveKitAPI(_http_url(), settings.LIVEKIT_API_KEY, settings.LIVEKIT_API_SECRET)
        await lk.room.delete_room(api.DeleteRoomRequest(room=room_name))
        await lk.aclose()
    except Exception as exc:  # noqa: BLE001
        logger.warning("Failed to delete LiveKit room %s: %s", room_name, exc)
