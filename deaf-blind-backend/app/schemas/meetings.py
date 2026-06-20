"""Video meeting request/response schemas."""
from datetime import datetime

from pydantic import Field

from app.schemas.common import ORMModel


class MeetingResponse(ORMModel):
    id: str
    title: str
    host_id: str
    code: str
    status: str
    created_at: datetime
    ended_at: datetime | None = None
    participant_count: int = 0


class CreateMeetingRequest(ORMModel):
    title: str = Field(default="Новый урок", max_length=200)


class JoinMeetingRequest(ORMModel):
    meeting_id: str | None = None
    code: str | None = None


class JoinMeetingResponse(ORMModel):
    meeting: MeetingResponse
    token: str
    livekit_url: str
    is_host: bool


class MeetingActionRequest(ORMModel):
    meeting_id: str


class DevTokenRequest(ORMModel):
    user_id: str = Field(min_length=1, max_length=128)
    display_name: str = Field(default="Guest", max_length=120)


class DevTokenResponse(ORMModel):
    access_token: str
    token_type: str = "bearer"
    user_id: str
    display_name: str
