"""§2 End-of-level exam: random subset of letters; pass unlocks next level."""


async def start_exam(student_id: int, level_id: int) -> dict:
    raise NotImplementedError


async def grade_exam(student_id: int, level_id: int, answers: list[dict]) -> dict:
    raise NotImplementedError
