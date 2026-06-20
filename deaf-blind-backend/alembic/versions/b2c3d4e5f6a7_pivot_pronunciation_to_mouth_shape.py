"""Pivot pronunciation_attempts to camera mouth-shape attempts

Replaces the audio/waveform attempt shape with derived mouth-metrics fields.

Revision ID: b2c3d4e5f6a7
Revises: a1b2c3d4e5f6
Create Date: 2026-06-20 21:30:00.000000

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


revision: str = "b2c3d4e5f6a7"
down_revision: Union[str, Sequence[str], None] = "a1b2c3d4e5f6"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    """Upgrade schema."""
    op.create_table(
        "pronunciation_attempts",
        sa.Column("id", sa.Integer(), autoincrement=True, nullable=False),
        sa.Column("student_id", sa.String(length=128), nullable=False),
        sa.Column("target_viseme", sa.String(length=32), nullable=False),
        sa.Column("metrics", sa.JSON(), nullable=False),
        sa.Column("coarse_score", sa.Float(), nullable=False, server_default="0"),
        sa.Column("feedback_text", sa.String(length=400), nullable=False, server_default=""),
        sa.Column(
            "created_at",
            sa.DateTime(timezone=True),
            server_default=sa.text("now()"),
            nullable=False,
        ),
        sa.PrimaryKeyConstraint("id"),
        if_not_exists=True,
    )
    op.create_index(
        "ix_pronunciation_attempts_student_id",
        "pronunciation_attempts",
        ["student_id"],
        unique=False,
        if_not_exists=True,
    )
    op.create_index(
        "ix_pronunciation_attempts_target_viseme",
        "pronunciation_attempts",
        ["target_viseme"],
        unique=False,
        if_not_exists=True,
    )


def downgrade() -> None:
    """Downgrade schema."""
    op.drop_index(
        "ix_pronunciation_attempts_target_viseme", table_name="pronunciation_attempts"
    )
    op.drop_index(
        "ix_pronunciation_attempts_student_id", table_name="pronunciation_attempts"
    )
    op.drop_table("pronunciation_attempts")
