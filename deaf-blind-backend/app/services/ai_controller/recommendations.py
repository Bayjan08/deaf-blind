"""§5 Turn the analytics summary into recommendations via the Gemini LLM."""
from app.integrations.gemini_client import GeminiClient

_gemini = GeminiClient()


async def recommend(student_id: int) -> dict:
    """Summarize performance data with the LLM -> weak areas + next lessons. Stub."""
    raise NotImplementedError
