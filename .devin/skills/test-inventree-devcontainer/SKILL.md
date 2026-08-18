---
name: test-inventree-devcontainer
description: Use when verifying the InvenTree Plugin AI Toolkit devcontainer builds, initializes, and runs after Python or InvenTree version bumps. Covers the full end-to-end flow from docker compose build through postCreateCommand.sh to a healthy server on http://localhost:8001.
---

# Test the InvenTree Plugin AI Toolkit devcontainer

**Purpose:** Verify that the devcontainer image builds, the one-time setup completes, and the InvenTree dev server serves the expected version.

---

## One-liner

From the toolkit root, after updating submodules and wiping stale volumes:

```powershell
docker compose -f .devcontainer/docker-compose.yml -f .devcontainer/docker-compose.frontend-volumes.yml up -d --build
docker compose -f .devcontainer/docker-compose.yml -f .devcontainer/docker-compose.frontend-volumes.yml exec -u vscode toolkit bash -c "cd /workspace && bash .devcontainer/postCreateCommand.sh"
cd /workspace/reference/inventree-source && invoke dev.server -a 0.0.0.0:8001
```

---

## Workflow

### 1. Align the InvenTree source submodule

The devcontainer points at `reference/inventree-source` and uses `invoke` tasks from it. The committed submodule pointer may lag `origin/stable`, which is where a new InvenTree release (and a new `MIN_PYTHON_VERSION`) can land.

```powershell
git submodule update --init --recursive --remote --force
```

**Completion criterion:** `reference/inventree-source/src/backend/InvenTree/InvenTree/version.py` shows the expected `INVENTREE_SW_VERSION` and `MIN_PYTHON_VERSION`. If the goal is to validate a Python version bump, `MIN_PYTHON_VERSION` must match the devcontainer base image.

### 2. Wipe stale data volumes when the Python base image changes

`/inventree-data/venv` is stored on a named Docker volume. `postCreateCommand.sh` creates it with `python3 -m venv`, which fails if the directory already exists. After a Python version bump, start from an empty volume.

```powershell
docker compose -f .devcontainer/docker-compose.yml -f .devcontainer/docker-compose.frontend-volumes.yml down -v
```

**Completion criterion:** `docker volume ls` no longer shows `devcontainer_inventree-data` before the next `up`.

### 3. Build and verify the toolkit image

```powershell
docker compose -f .devcontainer/docker-compose.yml -f .devcontainer/docker-compose.frontend-volumes.yml build --no-cache toolkit
```

**Completion criterion:**
- `docker compose ... build` exits `0`.
- `docker run --rm devcontainer-toolkit:latest python3 --version` prints `Python 3.x.y` matching `PYTHON_VERSION`.
- `docker run --rm devcontainer-toolkit:latest id vscode` shows `uid=1000(vscode)`.

### 4. Start the stack

```powershell
docker compose -f .devcontainer/docker-compose.yml -f .devcontainer/docker-compose.frontend-volumes.yml up -d
```

**Completion criterion:** `docker ps` shows `devcontainer-toolkit-1`, `devcontainer-db-1`, and `devcontainer-redis-1` all `Up`.

### 5. Run `postCreateCommand.sh`

The script can take 10-20 minutes. To avoid timeout issues, run it detached and poll a log file.

```powershell
docker compose -f .devcontainer/docker-compose.yml -f .devcontainer/docker-compose.frontend-volumes.yml exec -u vscode -d toolkit bash -c 'cd /workspace && bash .devcontainer/postCreateCommand.sh > /tmp/postCreateCommand.log 2>&1; echo $? > /tmp/postCreateCommand.exit'
```

Poll until `/tmp/postCreateCommand.exit` exists:

```powershell
docker compose -f .devcontainer/docker-compose.yml -f .devcontainer/docker-compose.frontend-volumes.yml exec toolkit bash -c 'test -f /tmp/postCreateCommand.exit && cat /tmp/postCreateCommand.exit || echo STILL_RUNNING; tail -n 30 /tmp/postCreateCommand.log'
```

**Completion criterion:**
- `/tmp/postCreateCommand.exit` contains `0`.
- `/tmp/postCreateCommand.log` does not contain `INVE-E15` or `Python version not supported`.
- `/tmp/postCreateCommand.log` contains `Devcontainer setup complete!`.
- `/inventree-data/venv/bin/python --version` inside the container is the expected Python version.

### 6. Start the dev server and verify health

```powershell
docker compose -f .devcontainer/docker-compose.yml -f .devcontainer/docker-compose.frontend-volumes.yml exec -u vscode -d toolkit bash -c 'cd /workspace/reference/inventree-source && invoke dev.server -a 0.0.0.0:8001 > /tmp/inventree-server.log 2>&1'
```

Poll from the host:

```powershell
curl.exe -s --max-time 10 http://localhost:8001/api/system/health/
```

**Completion criterion:** response is HTTP `200` with body `{"status":"ok"}`.

### 7. Browser verification (recorded)

Open `http://localhost:8001` and capture a screenshot. Expected result: the InvenTree login page loads, and the footer or network response confirms the expected InvenTree version.

---

## Common pitfalls

- **Stale `/inventree-data/venv` after a Python version bump.** `python3 -m venv` refuses to overwrite an existing, non-empty directory. Always run `docker compose ... down -v` when the base image Python version changes.
- **Submodule pointer lagging `origin/stable`.** A commit on `origin/stable` may introduce `MIN_PYTHON_VERSION = (3, 12)` while the submodule pointer still sits on an older release. Use `git submodule update --init --recursive --remote --force` and verify `version.py` before testing.
- **`postCreateCommand.sh` is long-running.** It installs Python packages, runs migrations, compiles the frontend, loads the demo dataset, installs plugin frontend dependencies, and installs Playwright browsers. Run it detached and poll the log.
- **`invoke dev.setup-dev` may emit a non-fatal `prek install` error.** `postCreateCommand.sh` runs `set +e` around this step and continues, but if a clean dev setup is required, investigate the git `dubious ownership` / `safe.directory` ordering in the script.
- **`INVE-W1` / `INVE-W10` warnings are normal in the devcontainer.** They reflect that the config directory is `/inventree-data` rather than `/home/inventree/dev` and that the source tree is in a detached HEAD state. They do not block server startup as long as `INVE-E15` is not present.

---

## Windows host / PYTHON_VERSION override notes

When testing a Python version bump, derive `PYTHON_VERSION` from the InvenTree submodule and export it before building:

```powershell
$env:PYTHON_VERSION = (python scripts/derive-python-version.py)
docker compose -f .devcontainer/docker-compose.yml -f .devcontainer/docker-compose.frontend-volumes.yml down -v
docker compose -f .devcontainer/docker-compose.yml -f .devcontainer/docker-compose.frontend-volumes.yml up -d --build
```

- To force the image to rebuild with the resolved `PYTHON_VERSION` (proving the build arg reached the base image), build the toolkit service directly:
  ```powershell
  docker compose -f .devcontainer/docker-compose.yml -f .devcontainer/docker-compose.frontend-volumes.yml build --no-cache toolkit
  ```
- `postCreateCommand.sh` downloads packages from PyPI. On flaky networks it can fail with `ResponseError('too many 502 error responses')`. Re-run it with extra pip retries:
  ```powershell
  docker compose -f .devcontainer/docker-compose.yml -f .devcontainer/docker-compose.frontend-volumes.yml exec -u vscode -d toolkit bash -c 'export PIP_RETRIES=10; export PIP_TIMEOUT=120; cd /workspace && bash .devcontainer/postCreateCommand.sh > /tmp/postCreateCommand.log 2>&1; echo $? > /tmp/postCreateCommand.exit'
  ```
- On Windows, `curl.exe` may not be available or may not return the health endpoint reliably. Use the Python one-liner from the host:
  ```powershell
  python -c "import urllib.request; print(urllib.request.urlopen('http://127.0.0.1:8001/api/system/health/').read().decode())"
  ```

## Devin Secrets Needed

None for local devcontainer verification. A `GITHUB_TOKEN` is required only if the test also interacts with the GitHub PR or issues.
