"""Security helpers — token verification, password/identity utilities.

Auth is Firebase-based (mobile signs in with Firebase, backend verifies ID tokens).
"""


async def verify_id_token(token: str) -> dict:
    """Verify a Firebase ID token and return its claims. Stub."""
    raise NotImplementedError
