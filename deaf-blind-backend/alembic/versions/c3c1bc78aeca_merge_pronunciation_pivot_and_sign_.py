"""merge pronunciation pivot and sign_phrase heads

Revision ID: c3c1bc78aeca
Revises: b2c3d4e5f6a7, b38684fa457d
Create Date: 2026-06-20 16:16:31.178288

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = 'c3c1bc78aeca'
down_revision: Union[str, Sequence[str], None] = ('b2c3d4e5f6a7', 'b38684fa457d')
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    """Upgrade schema."""
    pass


def downgrade() -> None:
    """Downgrade schema."""
    pass
