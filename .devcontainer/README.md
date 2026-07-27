# InvenTree Plugin AI Toolkit — Dev Container

This folder defines the reproducible development environment for the toolkit. It is built from standard Docker Compose and a Dockerfile, so it works with VS Code's Dev Containers extension **and** with plain `docker compose` commands from any terminal.

## Files

- `Dockerfile` — Debian-based Python/Node image for plugin development.
- `docker-compose.yml` — PostgreSQL, Redis, and the `toolkit` development service.
- `devcontainer.json` — VS Code-specific settings (extensions, forwarded ports, `postCreateCommand`). When you use plain Docker Compose, this file is ignored.
- `postCreateCommand.sh` — One-time setup: create the Python venv, install InvenTree and plugin dependencies, set up the dev database, and install Playwright browsers.

## CLI-only quick start

From the repository root:

```bash
# 1. Start the stack (PostgreSQL, Redis, and the toolkit container)
docker compose -f .devcontainer/docker-compose.yml up -d

# 2. (First time only) Run the one-time setup inside the toolkit container
docker compose -f .devcontainer/docker-compose.yml exec -u vscode toolkit bash -c "cd /workspace && bash .devcontainer/postCreateCommand.sh"

# 3. Open a shell in the dev environment
docker compose -f .devcontainer/docker-compose.yml exec -u vscode toolkit bash
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
docker compose -f .devcontainer/docker-compose.yml exec -u vscode toolkit bash -c "cd /workspace/plugins/inventree-flat-bom-generator && ./test-all.sh"
```

## Stopping

```bash
docker compose -f .devcontainer/docker-compose.yml down
```

Use `down -v` to also remove the PostgreSQL volume and start fresh.

## Notes

- The `toolkit` service uses `command: sleep infinity` so `docker compose up -d` keeps it alive for `docker exec`. VS Code sets `overrideCommand: true`, so this does not affect VS Code usage.
- Port `8001` is mapped `8001:8001` so `localhost:8001` is the same URL inside and outside the container.
- For VS Code usage, see `../SETUP.md`.
