FROM python:3.12-slim

# Don't write .pyc files; flush logs immediately (good for Cloud Run logs).
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app

# Install deps first so this layer is cached when only code changes.
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

# Run as a non-root user (security best practice).
RUN useradd --create-home appuser
USER appuser

# Cloud Run sends traffic to $PORT (default 9000).
ENV PORT=9000
EXPOSE 9000

# Shell form so $PORT expands at runtime.
CMD exec uvicorn main:app --host 0.0.0.0 --port ${PORT}
