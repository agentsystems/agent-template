"""Smoke tests for the agent-template.

These tests spin up the FastAPI app with TestClient (no network) and ensure the
three required endpoints respond with a 200 status code and expected JSON
structure. They are intended mainly as a guard against accidental edits when
users customise the template.
"""

from fastapi.testclient import TestClient

from main import app

client = TestClient(app)


def test_health():
    resp = client.get("/health")
    assert resp.status_code == 200
    body = resp.json()
    assert body.get("status") == "ok"


def test_metadata():
    resp = client.get("/metadata")
    assert resp.status_code == 200
    body = resp.json()
    assert "name" in body
    assert "version" in body


def test_invoke():
    payload = {"prompt": "hello"}
    resp = client.post("/invoke", json=payload)
    assert resp.status_code == 200
    data = resp.json()
    # Default logic echoes the prompt; customise as you like
    assert data["reply"].startswith("Echo")
    assert "timestamp" in data
