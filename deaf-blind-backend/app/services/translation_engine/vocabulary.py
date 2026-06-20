"""§1.7 Fixed vocabulary loader/lookup — the demo-limited supported phrases.

Backs both directions: text<->gesture_label<->avatar_animation. Seeded from the
SignPhrase table. Expandable post-hackathon.
"""


from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from app.models.sign_phrase import SignPhrase


async def get_all_vocabulary(db: AsyncSession, language: str = "ru") -> list[SignPhrase]:
    """Fetch all sign phrases from the database."""
    stmt = select(SignPhrase).where(SignPhrase.language == language)
    result = await db.execute(stmt)
    return list(result.scalars().all())


async def lookup_by_text(db: AsyncSession, text: str, language: str = "ru") -> int | None:
    """Return the avatar_animation_id for a known phrase, or None."""
    stmt = select(SignPhrase.avatar_animation_id).where(
        SignPhrase.text == text.lower().strip(),
        SignPhrase.language == language
    )
    result = await db.execute(stmt)
    return result.scalar_one_or_none()


async def lookup_by_label(db: AsyncSession, label: str) -> str | None:
    """Return the text for a recognized gesture label, or None."""
    stmt = select(SignPhrase.text).where(SignPhrase.gesture_label == label.lower().strip())
    result = await db.execute(stmt)
    return result.scalar_one_or_none()
