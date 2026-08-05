---
name: test-inventree-plugin
description: Use when the user or another skill wants to run tests for an InvenTree plugin. Triggers include "test", "run tests", "test-all", "test-all.sh", "pytest", "vitest", "Playwright", "how long do tests take", or before a deploy. Discovers the devcontainer and InvenTree server, runs the deterministic test suite, and falls back to host-side checks if the devcontainer is unavailable.
---

# Test an InvenTree plugin

**Purpose:** Run the full deterministic test suite for any plugin in `plugins/`.

---

## One-liner

From the toolkit root, with the devcontainer running:

```powershell
docker compose -f .devcontainer/docker-compose.yml -f .devcontainer/docker-compose.frontend-volumes.yml exec -u vscode toolkit bash -c "cd /workspace && bash scripts/run-test-all.sh /workspace/plugins/<PluginFolderName>"
```

If you are already inside the devcontainer:

```bash
bash scripts/run-test-all.sh /workspace/plugins/<PluginFolderName>
```

`scripts/run-test-all.sh` checks `http://localhost:8001/api/system/health/` first. If the server is already warm, it reuses it; otherwise it starts one, waits for it, then calls the plugin's `test-all.sh`.

---

## Workflow

### 1. Resolve the plugin

Ask the user for the plugin folder name if it is not already in context. The folder is the name under `plugins/`, not the Python module name.

**Completion criterion:** a valid `plugins\<PluginFolderName>` directory exists.

### 2. Discover the runtime environment

Run these checks from the toolkit root:

```powershell
# Is the devcontainer running?
docker ps --filter "name=toolkit" --format "{{.Names}}"

# Is the InvenTree server healthy?
(Invoke-RestMethod -Uri "http://localhost:8001/api/system/health/" -TimeoutSec 5).status -eq "ok"
```

Possible states:

- **Warm:** devcontainer is running and the server returns `ok`.
- **Container-only:** devcontainer is running, but the server is down.
- **Cold:** no devcontainer.

**Completion criterion:** the environment state is known.

### 3. Run the tests

- **Warm or container-only:** run the one-liner above. `run-test-all.sh` starts the server automatically if needed.
- **Cold:** ask the user whether to start the devcontainer. If yes:
  1. `docker compose -f .devcontainer/docker-compose.yml -f .devcontainer/docker-compose.frontend-volumes.yml up -d`
  2. Wait for the container to be ready.
  3. Run the one-liner.
- **Cold and user declines:** run the Windows host fallback below.

**Completion criterion:** the test command exits and the output is captured.

### 4. Report the result

Summarize:

- Pass/fail and exit code.
- Test counts (unit, integration, E2E).
- Per-layer timings and total wall-clock.
- Any failures and the next step.

**Completion criterion:** the summary is delivered to the user.

---

## Speed and scope controls

`test-all.sh` honors these environment flags. Pass them inside the `docker exec` command string.

| Flag | Effect |
|------|--------|
| `FAST=1` | Skip integration and E2E tests. |
| `SKIP_LINT=1` | Skip code-quality checks. |
| `SKIP_UNIT=1` | Skip Python unit tests. |
| `SKIP_INTEGRATION=1` | Skip Python integration tests. |
| `SKIP_FRONTEND=1` | Skip all frontend steps. |
| `SKIP_E2E=1` | Skip Playwright E2E (build still runs). |

Example with `FAST=1`:

```powershell
docker compose -f .devcontainer/docker-compose.yml -f .devcontainer/docker-compose.frontend-volumes.yml exec -u vscode toolkit bash -c "cd /workspace && FAST=1 bash scripts/run-test-all.sh /workspace/plugins/inventree-flat-bom-generator"
```

---

## Windows host fallback

If the devcontainer is not available, run the fast checks from the plugin directory. Replace `<ModuleName>` with the plugin's Python package name (e.g. `flat_bom_generator`):

```powershell
python -m pytest <ModuleName>/tests/unit -v
cd frontend
npm run lint
npm run test
npm run build
```

For flat-bom-specific fallback notes, see the per-plugin `testing-inventree-flat-bom` skill.

---

## Common pitfalls

- The full suite requires the devcontainer. `test-all.sh` exits quickly with an `INVENTREE_HOME` error if it is run outside it.
- Playwright E2E tests read credentials from `config/servers.json` and fall back to `admin`/`admin`.
- The `docker compose` command must use the same project name as the running container, or be run from the toolkit root with the same `-f` files, so it attaches to the existing devcontainer.
- Starting a cold devcontainer can take several minutes; the `FAST=1` one-liner is the fastest deterministic check.
