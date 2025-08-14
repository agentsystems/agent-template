# -----------------------------------------------------------------------------
# Agent Template - Generic Dockerfile for agents
# This uses a slim Python image and installs dependencies from requirements.txt
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# Builder stage – install deps and collect licenses
# -----------------------------------------------------------------------------
FROM python:3.13-slim AS builder

WORKDIR /build

# Install OS dependencies needed for building Python packages
RUN apt-get update \
    && apt-get install -y --no-install-recommends git \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements and install Python deps
COPY requirements.txt /tmp/
RUN pip install --upgrade pip \
    && pip install --no-cache-dir -r /tmp/requirements.txt

# ---- License collection ----
# 1) Install pip-licenses for license generation
RUN pip install --no-cache-dir pip-licenses

# 2) Collect Python dependency licenses
RUN mkdir -p /licenses/python \
    && pip freeze --exclude-editable > /licenses/python/THIRD_PARTY_REQUIREMENTS.txt \
    && pip-licenses \
        --format=json \
        --with-authors \
        --with-urls \
        --with-license-file \
        --no-license-path \
        > /licenses/python/THIRD_PARTY_LICENSES.json

# 3) Generate human-readable ATTRIBUTIONS.md
RUN python - <<'PY'
import json
p = "/licenses/python/THIRD_PARTY_LICENSES.json"
data = json.load(open(p))
out = "/licenses/python/ATTRIBUTIONS.md"
with open(out, "w", encoding="utf-8") as f:
    f.write("# Third-Party Python Packages\n\n")
    f.write("This agent template includes the following third-party Python packages:\n\n")
    for row in sorted(data, key=lambda r: r["Name"].lower()):
        f.write(f"## {row.get('Name','')} {row.get('Version','')}\n")
        f.write(f"- License: {row.get('License','Unknown')}\n")
        if row.get("URL"): f.write(f"- URL: {row['URL']}\n")
        if row.get("Author"): f.write(f"- Author: {row['Author']}\n")
        txt = row.get("LicenseText")
        if txt and len(txt) < 50000:  # Skip extremely long licenses in details
            f.write("\n<details><summary>License text</summary>\n\n")
            f.write("```\n")
            f.write(txt)
            f.write("\n```\n")
            f.write("</details>\n")
        f.write("\n")
PY

# 4) Collect any NOTICE files from installed packages
RUN mkdir -p /licenses/python_notices \
    && python - <<'PY'
import sys, pathlib, shutil
dest = pathlib.Path("/licenses/python_notices")
for p in map(pathlib.Path, sys.path):
    if p.exists() and "site-packages" in str(p):
        for item in p.iterdir():
            if item.is_dir():
                for name in ("NOTICE", "NOTICE.txt", "NOTICE.md", "NOTICE.rst"):
                    n = item / name
                    if n.exists():
                        shutil.copy2(n, dest / f"{item.name}-{name}")
PY

# 5) Collect Debian package licenses (for packages still installed)
RUN mkdir -p /licenses/debian \
    && for pkg in $(dpkg-query -W -f='${Package}\n'); do \
        src="/usr/share/doc/$pkg/copyright"; \
        if [ -f "$src" ]; then \
            cp "$src" "/licenses/debian/${pkg}-copyright"; \
        fi; \
    done

# -----------------------------------------------------------------------------
# Final stage – minimal runtime image
# -----------------------------------------------------------------------------
FROM python:3.13-slim

ENV PYTHONUNBUFFERED=1
WORKDIR /app

# Install runtime OS dependencies (git is only needed during build)
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        # Add any runtime OS deps here if needed
        # For now, we don't need any
    && rm -rf /var/lib/apt/lists/*

# Copy Python packages from builder
COPY --from=builder /usr/local/lib/python3.13/site-packages /usr/local/lib/python3.13/site-packages
COPY --from=builder /usr/local/bin /usr/local/bin

# Copy license information
COPY --from=builder /licenses /app/licenses

# Copy our own license
COPY LICENSE /app/LICENSE

# Copy application source
COPY . /app

# Add OCI labels
LABEL org.opencontainers.image.title="AgentSystems Agent Template" \
      org.opencontainers.image.description="Template for building AI agents with AgentSystems" \
      org.opencontainers.image.vendor="AgentSystems" \
      org.opencontainers.image.licenses="Apache-2.0" \
      org.opencontainers.image.license.files="/app/licenses" \
      org.opencontainers.image.source="https://github.com/agentsystems/agent-template"

# Create non-root user
RUN useradd -u 1001 appuser
USER 1001

EXPOSE 8000
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
