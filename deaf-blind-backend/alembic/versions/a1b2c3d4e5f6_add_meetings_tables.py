"""Add meetings tables for LiveKit video conferencing

Revision ID: a1b2c3d4e5f6
Revises: 90603c1ae75b
Create Date: 2026-06-20 19:00:00.000000

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


revision: str = "a1b2c3d4e5f6"
down_revision: Union[str, Sequence[str], None] = "90603c1ae75b"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    """Upgrade schema."""
    op.create_table(
        "meetings",
        sa.Column("id", sa.String(length=36), nullable=False),
        sa.Column("title", sa.String(length=200), nullable=False),
        sa.Column("host_id", sa.String(length=128), nullable=False),
        sa.Column("code", sa.String(length=8), nullable=False),
        sa.Column("status", sa.String(length=20), nullable=False, server_default="active"),
        sa.Column(
            "created_at",
            sa.DateTime(timezone=True),
            server_default=sa.text("now()"),
            nullable=False,
        ),
        sa.Column("ended_at", sa.DateTime(timezone=True), nullable=True),
        sa.PrimaryKeyConstraint("id"),
        sa.UniqueConstraint("code"),
        if_not_exists=True,
    )
    op.create_index("ix_meetings_host_id", "meetings", ["host_id"], unique=False, if_not_exists=True)
    op.create_index("ix_meetings_code", "meetings", ["code"], unique=False, if_not_exists=True)

    op.create_table(
        "meeting_participants",
        sa.Column("id", sa.Integer(), autoincrement=True, nullable=False),
        sa.Column("user_id", sa.String(length=128), nullable=False),
        sa.Column("meeting_id", sa.String(length=36), nullable=False),
        sa.Column("display_name", sa.String(length=120), nullable=False, server_default="Guest"),
        sa.Column(
            "joined_at",
            sa.DateTime(timezone=True),
            server_default=sa.text("now()"),
            nullable=False,
        ),
        sa.Column("left_at", sa.DateTime(timezone=True), nullable=True),
        sa.ForeignKeyConstraint(["meeting_id"], ["meetings.id"], ondelete="CASCADE"),
        sa.PrimaryKeyConstraint("id"),
        if_not_exists=True,
    )
    op.create_index(
        "ix_meeting_participants_user_id",
        "meeting_participants",
        ["user_id"],
        unique=False,
        if_not_exists=True,
    )
    op.create_index(
        "ix_meeting_participants_meeting_id",
        "meeting_participants",
        ["meeting_id"],
        unique=False,
        if_not_exists=True,
    )


def downgrade() -> None:
    """Downgrade schema."""
    op.drop_index("ix_meeting_participants_meeting_id", table_name="meeting_participants")
    op.drop_index("ix_meeting_participants_user_id", table_name="meeting_participants")
    op.drop_table("meeting_participants")
    op.drop_index("ix_meetings_code", table_name="meetings")
    op.drop_index("ix_meetings_host_id", table_name="meetings")
    op.drop_table("meetings")
