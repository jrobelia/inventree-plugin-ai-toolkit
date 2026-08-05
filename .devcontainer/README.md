# InvenTree Plugin AI Toolkit — Dev Container

This folder defines the reproducible development environment for the toolkit. It is built from standard Docker Compose and a Dockerfile, so it works with VS Code's Dev Containers extension **and** with plain `docker compose` commands from any terminal.

## Files

- `Dockerfile` — Debian-based Python/Node image for plugin development.
- `docker-compose.yml` — PostgreSQL, Redis, and the `toolkit` development service.
- `docker-compose.frontend-volumes.yml` — Generated overlay that mounts a named Docker volume for every plugin `frontend/node_modules` directory. This file is merged with `docker-compose.yml` by the devcontainer and in the CLI commands below.
- `frontend-node-modules-mounts.txt` — Generated list of `frontend/node_modules` container paths, used by the Dockerfile to pre-create mount points.
- `generate-frontend-volumes.py` — Host-side generator that produces the two generated files above from `plugins/*/frontend/package.json`.
- `devcontainer.json` — VS Code-specific settings (extensions, forwarded ports, `postCreateCommand`). When you use plain Docker Compose, this file is ignored.
- `postCreateCommand.sh` — One-time setup: create the Python venv, install InvenTree and plugin dependencies, set up the dev database, load the InvenTree demo dataset from a branch matching the pinned InvenTree version, install plugin frontend dependencies with `npm ci`, and install Playwright browsers.

## CLI-only quick start

From the repository root:

```bash
# 1. Start the stack (PostgreSQL, Redis, and the toolkit container)
docker compose -f .devcontainer/docker-compose.yml -f .devcontainer/docker-compose.frontend-volumes.yml up -d

# 2. (First time only) Run the one-time setup inside the toolkit container
docker compose -f .devcontainer/docker-compose.yml -f .devcontainer/docker-compose.frontend-volumes.yml exec -u vscode toolkit bash -c "cd /workspace && bash .devcontainer/postCreateCommand.sh"

# 3. Open a shell in the dev environment
docker compose -f .devcontainer/docker-compose.yml -f .devcontainer/docker-compose.frontend-volumes.yml exec -u vscode toolkit bash
```

Inside the container:

```bash
# Start the InvenTree server on port 8001
cd /workspace/reference/inventree-source
invoke dev.server -a 0.0.0.0:8001
```

The server is available at `http://localhost:8001` both inside the container and on the host.

## Running the full deterministic test suite

With the server running:

```bash
docker compose -f .devcontainer/docker-compose.yml -f .devcontainer/docker-compose.frontend-volumes.yml exec -u vscode toolkit bash -c "cd /workspace/plugins/inventree-flat-bom-generator && ./test-all.sh"
```

## Stopping

```bash
docker compose -f .devcontainer/docker-compose.yml -f .devcontainer/docker-compose.frontend-volumes.yml down
```

Use `down -v` to also remove the PostgreSQL volume and start fresh.

## Plugin frontend `node_modules`

Each plugin frontend keeps its `node_modules` tree on a named Docker volume instead of in the workspace bind mount. This avoids `EACCES` failures when tools like Vitest or `vite-plugin-externals` write into `node_modules`, and it hides any stale or root-owned `node_modules` that may exist on the host.

The named-volume mount points are generated from `plugins/*/frontend/package.json`. After adding a new plugin with a frontend, regenerate the overlay and rebuild the devcontainer:

```bash
# Run from the repository root
python .devcontainer/generate-frontend-volumes.py
docker compose -f .devcontainer/docker-compose.yml -f .devcontainer/docker-compose.frontend-volumes.yml down -v
docker compose -f .devcontainer/docker-compose.yml -f .devcontainer/docker-compose.frontend-volumes.yml up -d
```

Commit the generated `docker-compose.frontend-volumes.yml` and `frontend-node-modules-mounts.txt` so that other developers get the updated mount points.

## Notes

- The `toolkit` service uses `command: sleep infinity` so `docker compose up -d` keeps it alive for `docker exec`. VS Code sets `overrideCommand: true`, so this does not affect VS Code usage.
- Port `8001` is mapped `8001:8001` so `localhost:8001` is the same URL inside and outside the container.
- For VS Code usage, see `../SETUP.md`.
- The demo dataset branch is derived from `INVENTREE_SW_VERSION` in `reference/inventree-source`. When you bump the InvenTree submodule to a new major/minor version, update the derivation in `postCreateCommand.sh` (or pin to a known commit) and verify `invoke dev.setup-test -i` still loads cleanly.
