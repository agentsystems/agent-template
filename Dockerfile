# Generic Dockerfile for agents generated from agent-template
# This uses a slim Python image and installs dependencies from requirements.txt.

FROM python:3.12-slim

# Install OS + Python deps
COPY requirements.txt /tmp/
ARG GITHUB_TOKEN
RUN apt-get update \
    && apt-get install -y --no-install-recommends git \
    # Python deps
    && pip install --upgrade pip \
    && pip install --no-cache-dir -r /tmp/requirements.txt \
    && pip install "agentsystems-sdk[observe] @ git+https://${GITHUB_TOKEN}:x-oauth-basic@github.com/agentsystems/agentsystems-sdk@main" \
    # cleanup
    && apt-get purge -y --auto-remove git \
    && rm -rf /var/lib/apt/lists/*

# Copy source
WORKDIR /app
COPY . /app

# Run as non-root for better security
RUN useradd -u 1001 appuser
USER 1001

EXPOSE 8000
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
