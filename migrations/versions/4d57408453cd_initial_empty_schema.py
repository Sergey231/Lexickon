"""initial empty schema

Revision ID: 4d57408453cd
Revises:
Create Date: 2026-07-11 13:57:38.556383
"""

from collections.abc import Sequence

import sqlalchemy as sa
from alembic import op

revision: str = "4d57408453cd"
down_revision: str | None = None
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None


def upgrade() -> None:
    pass


def downgrade() -> None:
    pass
