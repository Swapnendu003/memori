FROM python:3.11-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app

# Install system dependencies needed for some Python packages
RUN apt-get update \
    && apt-get install -y --no-install-recommends build-essential gcc libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . .

# Create non-root user and set ownership
RUN groupadd -r app && useradd -r -g app app && chown -R app:app /app
USER app

# Expose a default port (overridden by Render via $PORT)
EXPOSE 5000

# Use the PORT env var if provided by the platform, fallback to 5000
ENTRYPOINT ["/bin/sh","-c","gunicorn -w 4 -b 0.0.0.0:${PORT:-5000} app:app"]
