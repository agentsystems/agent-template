# Generic Dockerfile for agents generated from agent-template
# This uses a slim Python image and installs dependencies from requirements.txt.

FROM python:3.12-slim

# Install Python dependencies
COPY requirements.txt /tmp/
RUN pip install --upgrade pip \
    && pip install --no-cache-dir -r /tmp/requirements.txt

# Copy source
WORKDIR /app
COPY . /app

# Run as non-root for better security
RUN useradd -u 1001 appuser
USER 1001

EXPOSE 8000
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
