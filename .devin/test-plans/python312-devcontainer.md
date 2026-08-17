# Test Plan: Python 3.12 devcontainer for InvenTree 1.5.0

## Goal

Prove that the `devin/python-3.12-devcontainer` branch upgrades the devcontainer image to Python 3.12 and that the full stack can initialise and run InvenTree 1.5.0 without hitting `INVE-E15: Python version not supported`.

## Evidence from code

- `.devcontainer/Dockerfile:6-7` now declares `ARG PYTHON_VERSION=3.12` and `FROM mcr.microsoft.com/devcontainers/python:${PYTHON_VERSION}-bookworm`.
- `.devcontainer/Dockerfile:34-39` no longer installs `python3.11-dev python3.11-venv`.
- `.devcontainer/docker-compose.yml:31-32` passes `PYTHON_VERSION: "3.12"` as a build arg.
- `SETUP.md:53` now documents Python 3.12.
- `reference/inventree-source/src/backend/InvenTree/InvenTree/version.py:18,21` (after updating the `stable` submodule) is `INVENTREE_SW_VERSION = '1.5.0'` and `MIN_PYTHON_VERSION = (3, 12)`.
- `reference/inventree-source/src/backend/InvenTree/InvenTree/version.py:76-87` defines `checkMinPythonVersion()`, which emits `INVE-E15` when the running Python is below `MIN_PYTHON_VERSION`. This is invoked during `invoke update -s` at `.devcontainer/postCreateCommand.sh:59`.
- `reference/inventree-source/tasks.py:1602` defines `dev.server` with `address='0.0.0.0:8000'`.

## Pre-test state

- Branch `devin/python-3.12-devcontainer` is checked out at `C:/Users/Administrator/repos/inventree-plugin-ai-toolkit`.
- `reference/inventree-source` has been updated to the `origin/stable` tip (commit `6a6736b8d`, tag `1.5.0`).
- Old devcontainer containers and volumes have been removed with `docker compose ... down -v` so the test starts from a clean data volume.

## Test steps

### 1. Build the `toolkit` image with the Python 3.12 Dockerfile

```powershell
cd C:/Users/Administrator/repos/inventree-plugin-ai-toolkit
docker compose -f .devcontainer/docker-compose.yml -f .devcontainer/docker-compose.frontend-volumes.yml build --no-cache toolkit
```

**Pass criteria**
- Exit code `0`.
- Image `devcontainer-toolkit` is created.
- Running `docker run --rm -it devcontainer-toolkit:latest python3 --version` returns `Python 3.12.x`.

### 2. Start the stack

```powershell
docker compose -f .devcontainer/docker-compose.yml -f .devcontainer/docker-compose.frontend-volumes.yml up -d
```

**Pass criteria**
- `docker ps` shows `devcontainer-toolkit-1`, `devcontainer-db-1`, and `devcontainer-redis-1` all `Up`.
- `docker volume ls` shows `devcontainer_inventree-data`.

### 3. Run the one-time setup and confirm no `INVE-E15`

```powershell
docker compose -f .devcontainer/docker-compose.yml -f .devcontainer/docker-compose.frontend-volumes.yml exec -u vscode -d toolkit bash -c "cd /workspace && bash .devcontainer/postCreateCommand.sh > /tmp/postCreateCommand.log 2>&1; echo \$? > /tmp/postCreateCommand.exit"
```

Poll until `/tmp/postCreateCommand.exit` exists, then read it.

```powershell
docker compose -f .devcontainer/docker-compose.yml -f .devcontainer/docker-compose.frontend-volumes.yml exec toolkit cat /tmp/postCreateCommand.exit
```

**Pass criteria**
- Exit code `0`.
- `/tmp/postCreateCommand.log` does **not** contain the text `INVE-E15`.
- `/tmp/postCreateCommand.log` does **not** contain `Python version not supported`.
- `/tmp/postCreateCommand.log` contains `Devcontainer setup complete!`.
- Inside the container, `/inventree-data/venv/bin/python --version` returns `Python 3.12.x`.

### 4. Start the InvenTree dev server

```powershell
docker compose -f .devcontainer/docker-compose.yml -f .devcontainer/docker-compose.frontend-volumes.yml exec -u vscode -d toolkit bash -c "cd /workspace/reference/inventree-source && nohup invoke dev.server -a 0.0.0.0:8001 > /tmp/inventree-server.log 2>&1 & sleep 5; echo \$? > /tmp/server-start.exit"
```

**Pass criteria**
- `/tmp/server-start.exit` returns `0`.
- `docker compose ... exec toolkit pgrep -f 'manage.py runserver'` (or equivalent) finds the server process.

### 5. Verify the server responds at `http://localhost:8001`

Poll the health endpoint from the host:

```powershell
curl.exe -s --max-time 5 http://localhost:8001/api/system/health/
```

**Pass criteria**
- HTTP status `200`.
- JSON body contains `"status": "ok"`.

### 6. Browser check (recorded)

1. Start screen recording.
2. Open Chrome and navigate to `http://localhost:8001` (or the health endpoint `http://localhost:8001/api/system/health/`).
3. Capture a screenshot showing the server response / login page.

**Pass criteria**
- Browser visibly loads a page served by InvenTree at `http://localhost:8001`.
- If on the login page, it shows InvenTree branding; if on the health endpoint, it shows JSON with `status: ok`.

## Stop/cleanup after test

```powershell
docker compose -f .devcontainer/docker-compose.yml -f .devcontainer/docker-compose.frontend-volumes.yml down
```
