"""Minimal FastAPI entry-point for a containerised AI agent.

This file is intended as part of the `agent-template` cookie-cutter.  When a new
agent is generated, users will typically customise:
  • the Pydantic request/response schemas
  • the implementation inside `invoke()`

The runtime contract expected by the Agent Control Plane is:
  POST /invoke    – main inference/action endpoint
  GET  /health    – liveness probe
  GET  /metadata  – YAML metadata from `agent.yaml`
"""

from datetime import datetime
from typing import Any, Dict

import pathlib

import yaml
from fastapi import FastAPI
from pydantic import BaseModel

# ── Load static metadata once at startup ──────────────────────────────────────
meta_path = pathlib.Path(__file__).with_name("agent.yaml")
if not meta_path.exists():
    raise FileNotFoundError("agent.yaml not found next to main.py – required by template")

meta: Dict[str, Any] = yaml.safe_load(meta_path.read_text())
NAME: str = meta.get("name", "UnnamedAgent")
VERSION: str = meta.get("version", "0.0.0")

app = FastAPI(title=NAME, version=VERSION)


# ── Pydantic Schemas – replace with your own ─────────────────────────────────
class InvokeRequest(BaseModel):
    prompt: str


class InvokeResponse(BaseModel):
    reply: str
    timestamp: datetime


# ── Routes – minimal contract ────────────────────────────────────────────────
@app.post("/invoke", response_model=InvokeResponse, tags=["Agent Ops"])
async def invoke(req: InvokeRequest) -> InvokeResponse:  # noqa: D401
    """Echo back the prompt with a timestamp. Replace with real logic."""
    return InvokeResponse(reply=f"Echo: {req.prompt}", timestamp=datetime.utcnow())


@app.get("/health", tags=["Agent Ops"])
async def health() -> Dict[str, str]:
    return {"status": "ok", "version": VERSION}


@app.get("/metadata", tags=["Agent Ops"])
async def metadata() -> Dict[str, Any]:
    return meta
