"""§1 WebRTC signaling SEAM (out of hackathon scope).

Drop-in point for LiveKit/Agora to carry the actual A/V streams. The translation
relay (captions/labels) works over Socket.IO without this.
"""


async def issue_join_token(session_id: int, user_id: int) -> str:
    """Return a provider join token for the video room. Not implemented (roadmap)."""
    raise NotImplementedError
