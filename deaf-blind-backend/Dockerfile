FROM python:3.12-slim

# Don't write .pyc files; flush logs immediately (good for Cloud Run logs).
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app

# Install deps first so Docker caches this layer when only code changes.
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

# Cloud Run sends traffic to $PORT (default 8080). Bind to it.
ENV PORT=8080
EXPOSE 8080

# Use shell form so $PORT expands at runtime.
CMD exec uvicorn main:app --host 0.0.0.0 --port ${PORT}
