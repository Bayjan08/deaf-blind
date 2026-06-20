"""ORM models. Importing here ensures Base.metadata registers every table."""
from app.models.class_session import ClassSession
from app.models.exam_result import ExamResult
from app.models.lesson import Lesson
from app.models.letter import Letter
from app.models.level import Level
from app.models.music_note import MusicNote
from app.models.music_progress import MusicProgress
from app.models.performance_log import PerformanceLog
from app.models.pet import Pet
from app.models.pet_house import PetHouse
from app.models.pronunciation_attempt import PronunciationAttempt
from app.models.recommendation import Recommendation
from app.models.session_participant import SessionParticipant
from app.models.sign_phrase import SignPhrase
from app.models.student_progress import StudentProgress
from app.models.user import User
from app.models.video_job import VideoJob

__all__ = [
    "ClassSession",
    "ExamResult",
    "Lesson",
    "Letter",
    "Level",
    "MusicNote",
    "MusicProgress",
    "PerformanceLog",
    "Pet",
    "PetHouse",
    "PronunciationAttempt",
    "Recommendation",
    "SessionParticipant",
    "SignPhrase",
    "StudentProgress",
    "User",
    "VideoJob",
]
