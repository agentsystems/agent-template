# Agent Template

This repository provides the minimal scaffold used by **Agent Control Plane** to generate containerised FastAPI agents.

## Contents

| File / dir     | Purpose |
| -------------- | ------------------------------------------------------------- |
| `main.py`      | FastAPI entry-point implementing `/invoke`, `/health`, `/metadata`. |
| `agent.yaml`   | Declarative metadata consumed by the control-plane. |
| `Dockerfile`   | Reference Docker build (Python 3.12-slim + `requirements.txt`). |
| `requirements.txt` | Runtime Python dependencies. |

## Getting Started

1. Clone this repo (or let `agenctl init` do it for you).
2. Edit `agent.yaml` (`name`, `description`, etc.).
3. Extend the Pydantic request/response models in `main.py` and replace the logic in `invoke()`.
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

## Contributing

Pull requests welcome! This repo is MIT-licensed so you can adapt it freely.
