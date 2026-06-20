"""Video meeting lifecycle orchestration."""
import uuid

from fastapi import HTTPException, status
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.config import settings
from app.core.security import TokenPayload
from app.models.meeting import Meeting
from app.models.meeting_participant import MeetingParticipant
from app.schemas.meetings import MeetingResponse
from app.services.meetings import livekit_client, meeting_repo


async def create_meeting(
    db: AsyncSession,
    user: TokenPayload,
    title: str,
) -> tuple[MeetingResponse, str, str]:
    meeting_id = str(uuid.uuid4())
    code = meeting_repo.generate_meeting_code()

    for _ in range(5):
        existing = await db.execute(select(Meeting.id).where(Meeting.code == code))
        if existing.scalar_one_or_none() is None:
            break
        code = meeting_repo.generate_meeting_code()
    else:
        raise HTTPException(status_code=500, detail="Could not generate meeting code")

    meeting = Meeting(
        id=meeting_id,
        title=title.strip() or "Новый урок",
        host_id=user.user_id,
        code=code,
        status="active",
    )
    db.add(meeting)
    await db.flush()
    db.add(
        MeetingParticipant(
            user_id=user.user_id,
            meeting_id=meeting.id,
            display_name=user.display_name,
        )
    )
    await db.commit()
    await db.refresh(meeting)

    await livekit_client.create_livekit_room(meeting.id)
    token = livekit_client.create_livekit_token(
        room_name=meeting.id,
        identity=user.user_id,
        display_name=user.display_name,
        is_host=True,
    )
    count = await meeting_repo.active_participant_count(db, meeting.id)
    return meeting_repo.meeting_to_response(meeting, count), token, settings.LIVEKIT_PUBLIC_URL


async def join_meeting(
    db: AsyncSession,
    user: TokenPayload,
    *,
    meeting_id: str | None,
    code: str | None,
) -> tuple[MeetingResponse, str, str, bool]:
    if not meeting_id and not code:
        raise HTTPException(status_code=400, detail="Provide meeting_id or code")

    meeting = await meeting_repo.find_meeting(db, meeting_id=meeting_id, code=code)
    if meeting is None:
        raise HTTPException(status_code=404, detail="Invalid meeting code")
    meeting_repo.ensure_active(meeting)

    active = await meeting_repo.get_active_participant(db, meeting.id, user.user_id)
    if active is None:
        db.add(
            MeetingParticipant(
                user_id=user.user_id,
                meeting_id=meeting.id,
                display_name=user.display_name,
            )
        )
    await db.commit()

    is_host = meeting.host_id == user.user_id
    token = livekit_client.create_livekit_token(
        room_name=meeting.id,
        identity=user.user_id,
        display_name=user.display_name,
        is_host=is_host,
    )
    count = await meeting_repo.active_participant_count(db, meeting.id)
    return (
        meeting_repo.meeting_to_response(meeting, count),
        token,
        settings.LIVEKIT_PUBLIC_URL,
        is_host,
    )


async def leave_meeting(db: AsyncSession, user: TokenPayload, meeting_id: str) -> MeetingResponse:
    from datetime import UTC, datetime

    meeting = await meeting_repo.get_meeting_or_404(db, meeting_id)
    participant = await meeting_repo.get_active_participant(db, meeting_id, user.user_id)
    if participant is None:
        raise HTTPException(status_code=404, detail="You are not in this meeting")

    participant.left_at = datetime.now(UTC)
    await db.commit()
    count = await meeting_repo.active_participant_count(db, meeting_id)
    return meeting_repo.meeting_to_response(meeting, count)


async def end_meeting(db: AsyncSession, user: TokenPayload, meeting_id: str) -> MeetingResponse:
    from datetime import UTC, datetime

    meeting = await meeting_repo.get_meeting_or_404(db, meeting_id)
    if meeting.host_id != user.user_id:
        raise HTTPException(status_code=403, detail="Only the host can end the meeting")
    if meeting.status == "ended":
        raise HTTPException(status_code=410, detail="Meeting already ended")

    meeting.status = "ended"
    meeting.ended_at = datetime.now(UTC)
    await meeting_repo.mark_all_participants_left(db, meeting_id, meeting.ended_at)
    await db.commit()
    await livekit_client.delete_livekit_room(meeting_id)
    return meeting_repo.meeting_to_response(meeting, 0)


async def get_meeting(db: AsyncSession, meeting_id: str) -> MeetingResponse:
    meeting = await meeting_repo.get_meeting_or_404(db, meeting_id)
    count = await meeting_repo.active_participant_count(db, meeting_id)
    return meeting_repo.meeting_to_response(meeting, count)


async def list_recent_meetings(
    db: AsyncSession,
    user: TokenPayload,
    limit: int = 10,
) -> list[MeetingResponse]:
    meetings = await meeting_repo.list_user_meetings(db, user.user_id, limit)
    responses: list[MeetingResponse] = []
    for meeting in meetings:
        count = await meeting_repo.active_participant_count(db, meeting.id)
        responses.append(meeting_repo.meeting_to_response(meeting, count))
    return responses
