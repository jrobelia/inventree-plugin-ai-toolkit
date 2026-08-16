---
name: inventree-devcontainer-testing
description: Run the InvenTree Plugin AI Toolkit devcontainer and execute a plugin's test-all.sh. Covers Docker setup, postCreateCommand, server startup, and the lint/unit/integration/frontend-build/E2E layers.
---

# InvenTree Plugin AI Toolkit devcontainer testing

Use this skill when asked to validate the devcontainer setup or run a plugin's `test-all.sh` inside `inventree-plugin-ai-toolkit`.

## Devin Secrets Needed

- `GITHUB_TOKEN` may be needed if the test process clones public plugin repos from GitHub at high frequency.

## Environment assumptions

- Host is Windows with Docker Desktop/WSL2 backend.
- Docker Desktop service may be stopped at session start; start `com.docker.service` before any `docker` commands.
- Repo is at `C:\Users\Administrator\repos\inventree-plugin-ai-toolkit` (also `/workspace` in the container).
- Submodules and plugin clones under `plugins/` should already be populated.
- On Windows, files may be checked out with CRLF. Set `core.autocrlf false` / `core.eol lf` and normalize `*.sh` and plugin `frontend/src/**/*.{ts,tsx}` before running bash scripts.

## Quick start

1. Start Docker Desktop service if necessary:
   ```powershell
   Start-Service -Name com.docker.service
   ```

2. Bring up the devcontainer:
   ```powershell
   docker compose -f .devcontainer/docker-compose.yml -f .devcontainer/docker-compose.frontend-volumes.yml up -d --build
   ```

3. Normalize line endings (run inside the container after submodules/plugin repos are populated):
   ```powershell
   docker compose -f .devcontainer/docker-compose.yml -f .devcontainer/docker-compose.frontend-volumes.yml exec -u vscode toolkit bash -c "git config --global core.autocrlf false && git config --global core.eol lf && find /workspace -path '*/.git' -prune -o -path '*/node_modules' -prune -o -name '*.sh' -print0 | xargs -0 -r sed -i 's/\\r$//' && find /workspace/plugins -path '*/node_modules' -prune -o -path '*/frontend/src*' -name '*.ts' -print0 | xargs -0 -r sed -i 's/\\r$//' && find /workspace/plugins -path '*/node_modules' -prune -o -path '*/frontend/src*' -name '*.tsx' -print0 | xargs -0 -r sed -i 's/\\r$//'"
   ```

4. Run the post-create setup inside the toolkit container:
   ```powershell
   docker compose -f .devcontainer/docker-compose.yml -f .devcontainer/docker-compose.frontend-volumes.yml exec -u vscode toolkit bash -c "cd /workspace && bash .devcontainer/postCreateCommand.sh"
   ```

5. Start the InvenTree dev server in the background:
   ```powershell
   docker compose -f .devcontainer/docker-compose.yml -f .devcontainer/docker-compose.frontend-volumes.yml exec -u vscode toolkit bash -c "cd /workspace/reference/inventree-source && nohup invoke dev.server -a 0.0.0.0:8001 > /tmp/inventree-server.log 2>&1 &"
   ```

6. Wait for health:
   ```powershell
   docker compose -f .devcontainer/docker-compose.yml -f .devcontainer/docker-compose.frontend-volumes.yml exec -u vscode toolkit bash -c "for i in {1..60}; do curl -s -o /dev/null -w '%{http_code}' http://localhost:8001/api/system/health/ | grep -q 200 && break; sleep 2; done"
   ```

7. Run the full test suite for the flat-bom plugin:
   ```powershell
   docker compose -f .devcontainer/docker-compose.yml -f .devcontainer/docker-compose.frontend-volumes.yml exec -u vscode toolkit bash -c "cd /workspace && bash scripts/run-test-all.sh plugins/inventree-flat-bom-generator"
   ```

## Common blockers and workarounds

- **CRLF line endings in shell scripts**: On a Windows host, `.sh` files may be checked out with CRLF and bash fails with `set: -\r: invalid option` or `syntax error near unexpected token`. Normalize with `dos2unix` or `find . -name '*.sh' -exec sh -c 'f=$1; tr -d "\\r" < "$f" > "$f.tmp" && mv "$f.tmp" "$f"' _ {} \;` inside the container before running.
- **CRLF in frontend TypeScript files**: `npm run lint` (Biome) fails with format diagnostics showing `\r`/`\n` markers. Normalize `frontend/src/**/*.{ts,tsx}` to LF before running `test-all.sh`.
- **prek install / git hooks**: `invoke dev.setup-dev` may fail because of dubious-ownership or missing `prek`. `postCreateCommand.sh` wraps this with `set +e`, so the script usually continues; verify the dataset exists (`Part.objects.count() > 0`) before relying on it.
- **Display/Playwright**: The container sets `DISPLAY=:0` and `LIBGL_ALWAYS_INDIRECT=1`; Playwright works headless in CI. If browser deps are missing, `postCreateCommand.sh` runs `npx playwright install-deps`.
- **Server start in container**: `invoke dev.server` binds to `0.0.0.0:8001` so the port-forward `8001:8001` works from the host and inside the container.

## What a passing run looks like

- `Preflight checks passed` appears.
- `✓ Code quality checks passed` with no `ruff` or `npm run lint` errors.
- Python unit tests all pass, then `✓ Unit tests passed`.
- Frontend unit tests pass, then `✓ Frontend unit tests passed`.
- Python integration tests all pass, then `✓ Integration tests passed`.
- `npm run build` succeeds, then `✓ Frontend build passed`.
- Playwright E2E tests all pass, then `✓ E2E tests passed`.
- Final output contains `All tests passed successfully!` and exit code is `0`.

## Fallback

If the full run is blocked by an environment issue (e.g., Playwright display deps not available), use `FAST=1 bash test-all.sh` for lint + unit tests only, and report the blocker explicitly.
