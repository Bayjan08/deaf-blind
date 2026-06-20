"""§2 Letter lesson flow: intro -> practice -> feedback -> next."""


async def get_lesson(lesson_id: int) -> dict:
    raise NotImplementedError


async def record_attempt(student_id: int, lesson_id: int, correct: bool, confidence: float) -> None:
    """Persist the attempt + write a §5 PerformanceLog row. Stub."""
    raise NotImplementedError
