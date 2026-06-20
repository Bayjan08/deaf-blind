"""Video meeting REST endpoints (LiveKit-backed)."""
from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.dependencies.auth import get_current_user
from app.core.security import TokenPayload
from app.db.session import get_db
from app.schemas.meetings import (
    CreateMeetingRequest,
    JoinMeetingRequest,
    JoinMeetingResponse,
    MeetingActionRequest,
    MeetingResponse,
)
from app.services.meetings import service as meeting_service

router = APIRouter(prefix="/meetings", tags=["meetings"])


@router.post("/create", response_model=JoinMeetingResponse)
async def create_meeting(
    body: CreateMeetingRequest,
    user: TokenPayload = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Create a meeting and return LiveKit connection details for the host."""
    meeting, token, livekit_url = await meeting_service.create_meeting(
        db, user, body.title
    )
    return JoinMeetingResponse(
        meeting=meeting,
        token=token,
        livekit_url=livekit_url,
        is_host=True,
    )


@router.post("/join", response_model=JoinMeetingResponse)
async def join_meeting(
    body: JoinMeetingRequest,
    user: TokenPayload = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Join an existing meeting by ID or short code."""
    meeting, token, livekit_url, is_host = await meeting_service.join_meeting(
        db,
        user,
        meeting_id=body.meeting_id,
        code=body.code,
    )
    return JoinMeetingResponse(
        meeting=meeting,
        token=token,
        livekit_url=livekit_url,
        is_host=is_host,
    )


@router.post("/leave", response_model=MeetingResponse)
async def leave_meeting(
    body: MeetingActionRequest,
    user: TokenPayload = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Leave a meeting and update participant count."""
    return await meeting_service.leave_meeting(db, user, body.meeting_id)


@router.post("/end", response_model=MeetingResponse)
async def end_meeting(
    body: MeetingActionRequest,
    user: TokenPayload = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Host-only: end the meeting and disconnect all participants."""
    return await meeting_service.end_meeting(db, user, body.meeting_id)


@router.get("/recent", response_model=list[MeetingResponse])
async def recent_meetings(
    user: TokenPayload = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """List recent meetings for the authenticated user."""
    return await meeting_service.list_recent_meetings(db, user)


@router.get("/{meeting_id}", response_model=MeetingResponse)
async def get_meeting(
    meeting_id: str,
    user: TokenPayload = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Get meeting details by ID."""
    return await meeting_service.get_meeting(db, meeting_id)


