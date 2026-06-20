"""User schemas."""
from app.schemas.common import ORMModel


class UserOut(ORMModel):
    id: int
    display_name: str
    role: str
    locale: str
