"""§6 Video job lifecycle: create from upload, query status."""


async def create_job(student_id: int, source_url: str) -> dict:
    raise NotImplementedError


async def get_job(job_id: int) -> dict:
    raise NotImplementedError
