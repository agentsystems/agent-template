# Contributing to `agent-template`

Thank you for improving the Agent Template!  This repo is the starting point for new Agents, so keeping it lint-clean and easy to onboard is critical.

---
## Dev environment setup

```bash
# 1. (optional) create a Python virtualenv
python -m venv .venv && source .venv/bin/activate

# 2. install dev dependencies and git hooks
pip install -r requirements-dev.txt
pre-commit install

# 3. lint the full repo (auto-fix imports, formatting, etc.)
pre-commit run --all-files
```

The hooks run automatically on every `git commit` and include **ruff**, **black**, **shellcheck**, and **hadolint** to enforce consistent style.

---
## Opening a PR

1. Keep changes focused – one feature or bug-fix per PR.
2. Add tests if you add behaviour.
3. Ensure `pre-commit run --all-files` exits with code 0.
4. Use conventional commits (`feat: …`, `fix: …`, `chore: …`).

Happy hacking!
