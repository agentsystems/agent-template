# Agent Template

This repository provides the minimal scaffold used by **Agent Control Plane** to generate containerised FastAPI agents.

## Contents

| File / dir     | Purpose |
| -------------- | ------------------------------------------------------------- |
| `main.py`      | FastAPI entry-point implementing `/invoke`, `/health`, `/metadata`. |
| `agent.yaml`   | Declarative metadata consumed by the control-plane. |
| `Dockerfile`   | Reference Docker build (Python 3.12-slim + `requirements.txt`). |
| `requirements.txt` | Runtime Python dependencies. |

## Getting Started (local)


1. Clone this repo (or let `agenctl init` do it for you).
2. Edit `agent.yaml` (`name`, `description`, etc.).
3. Extend the Pydantic request/response models in `main.py` and replace the logic in `invoke()`.

   **Request contract**
   - Body must include `user_uid` (string) and any other agent-specific fields.
   - Gateway will add the header `X-Thread-Id: <uuid>` to each request.

   **Response contract**
   - JSON must include the same `thread_id` so audit logs can correlate request/response pairs.

   Example curl (once the agent is behind the gateway):
   ```bash
   curl -X POST localhost:8080/my-agent \
        -H 'Content-Type: application/json' \
        -d '{"user_uid": "user-123", "prompt": "Hello"}'
   ```
   Response:
   ```json
   {
     "thread_id": "550e8400-e29b-41d4-a716-446655440000",
     "reply": "Echo: Hello",
     "timestamp": "2025-06-16T09:34:00Z"
   }
   ```
4. Build & run locally:

```bash
docker build -t my-agent .
docker run -p 8000:8000 my-agent
```

5. Test:

```bash
curl -X POST localhost:8000/invoke -H 'Content-Type: application/json' \
     -d '{"prompt": "Hello"}'
```



## Using in deployments

In production you usually build & push the image, then reference it in the deployment bundle stored in [`agent-platform-deployments`](https://github.com/agentsystems/agent-platform-deployments`).

```
# example snippet in compose/local/docker-compose.yml
my-agent:
  image: mycorp/my-agent:1.0
  labels:
    - agent.enabled=true
    - agent.port=8000
```

The Gateway will auto-discover the container and route `POST /my-agent` to its `/invoke` endpoint.

---

## Contributing

Pull requests welcome! This repo is MIT-licensed so you can adapt it freely.
