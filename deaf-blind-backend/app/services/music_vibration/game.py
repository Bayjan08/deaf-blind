"""§3 Recognition game: present a vibration/color, student identifies the note."""


async def next_round(student_id: int) -> dict:
    raise NotImplementedError


async def submit_answer(student_id: int, note_id: int, chosen_id: int) -> dict:
    raise NotImplementedError
