"""Auth: verify Firebase token, upsert the User, return a session."""


async def login(id_token: str) -> dict:
    raise NotImplementedError
