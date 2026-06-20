"""Meeting database queries and response mapping."""
import secrets
import string
from datetime import datetime

from fastapi import HTTPException, status
from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload

from app.models.meeting import Meeting
from app.models.meeting_participant import MeetingParticipant
from app.schemas.meetings import MeetingResponse

_CODE_ALPHABET = string.ascii_uppercase + string.digits


def generate_meeting_code(length: int = 6) -> str:
    return "".join(secrets.choice(_CODE_ALPHABET) for _ in range(length))


def meeting_to_response(meeting: Meeting, participant_count: int) -> MeetingResponse:
    return MeetingResponse(
        id=meeting.id,
        title=meeting.title,
        host_id=meeting.host_id,
        code=meeting.code,
        status=meeting.status,
        created_at=meeting.created_at,
        ended_at=meeting.ended_at,
        participant_count=participant_count,
    )


async def active_participant_count(db: AsyncSession, meeting_id: str) -> int:
    result = await db.execute(
        select(func.count(MeetingParticipant.id)).where(
            MeetingParticipant.meeting_id == meeting_id,
            MeetingParticipant.left_at.is_(None),
        )
    )
    return int(result.scalar_one())


async def get_meeting_or_404(db: AsyncSession, meeting_id: str) -> Meeting:
    result = await db.execute(select(Meeting).where(Meeting.id == meeting_id))
    meeting = result.scalar_one_or_none()
    if meeting is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Meeting not found")
    return meeting


def ensure_active(meeting: Meeting) -> None:
    if meeting.status != "active":
        raise HTTPException(status_code=status.HTTP_410_GONE, detail="Meeting has ended")


async def find_meeting(
    db: AsyncSession,
    *,
    meeting_id: str | None,
    code: str | None,
) -> Meeting | None:
    query = select(Meeting)
    if meeting_id:
        query = query.where(Meeting.id == meeting_id)
    elif code:
        query = query.where(Meeting.code == code.strip().upper())
    else:
        return None
    result = await db.execute(query)
    return result.scalar_one_or_none()


async def get_active_participant(
    db: AsyncSession,
    meeting_id: str,
    user_id: str,
) -> MeetingParticipant | None:
    result = await db.execute(
        select(MeetingParticipant).where(
            MeetingParticipant.meeting_id == meeting_id,
            MeetingParticipant.user_id == user_id,
            MeetingParticipant.left_at.is_(None),
        )
    )
    return result.scalar_one_or_none()


async def mark_all_participants_left(db: AsyncSession, meeting_id: str, left_at: datetime) -> None:
    result = await db.execute(
        select(MeetingParticipant).where(
            MeetingParticipant.meeting_id == meeting_id,
            MeetingParticipant.left_at.is_(None),
        )
    )
    for participant in result.scalars():
        participant.left_at = left_at


async def list_user_meetings(
    db: AsyncSession,
    user_id: str,
    limit: int = 10,
) -> list[Meeting]:
    result = await db.execute(
        select(Meeting)
        .join(MeetingParticipant, MeetingParticipant.meeting_id == Meeting.id)
        .where(MeetingParticipant.user_id == user_id)
        .order_by(Meeting.created_at.desc())
        .distinct()
        .limit(limit)
        .options(selectinload(Meeting.participants))
    )
    return list(result.scalars().all())
