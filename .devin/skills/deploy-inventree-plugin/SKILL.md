---
name: deploy-inventree-plugin
description: Deploy a built InvenTree plugin .whl to a staging or production server. Requires config/servers.json and SSH key authentication. Always deploy to staging first.
disable-model-invocation: true
---

# Deploy an InvenTree plugin

**Purpose:** Install a built `.whl` package on a remote InvenTree server and verify it comes back healthy.

---

## One-liner

From the toolkit root, on the Windows host:

```powershell
.\scripts\Deploy-Plugin.ps1 -Plugin "<PluginFolderName>" -Server staging
```

---

## Workflow

### 1. Identify the plugin and target server

Ask the user for the plugin folder name and confirm `staging` or `production`. For `production`, the script requires typed `yes` confirmation and should only run after staging has been manually tested.

### 2. Verify server configuration

Open `config\servers.json` and confirm the requested server entry exists with at least:

```json
{
  "url": "https://staging.example.com",
  "ssh": {
    "host": "staging.server.com",
    "user": "inventree",
    "port": 22,
    "key_file": "C:/Users/<user>/.ssh/id_ed25519"
  }
}
```

Optional overrides (if auto-detection fails or you want to be explicit):

| Field | Default | Meaning |
|-------|---------|---------|
| `compose_dir` | auto-detected | Directory containing the InvenTree `compose.yaml` / `docker-compose.yml` |
| `service_name` | `inventree-server` | Docker Compose service name for the InvenTree server container |
| `data_dir` | `<compose_dir>/inventree-data` | Host path where the wheel is uploaded before being mounted into the container |
| `container_data_path` | `/home/inventree/data` | Container path matching the data volume mount |
| `docker_command` | auto-detected (`docker compose` or `docker-compose`) | Docker Compose command on the remote |

### 3. Build if needed

`Deploy-Plugin.ps1` calls `scripts/build-plugin.sh` inside the devcontainer if the `dist/` directory is missing or if source files are newer than the wheel. To force a build, use `-Build`.

### 4. Deploy

Run the one-liner from the top of this skill, adding switches as needed.

Switches:

| Switch | Meaning |
|--------|---------|
| `-Build` | Force a build before deploying |
| `-SkipRestart` | Install the wheel but do not restart the InvenTree container |
| `-SkipCollect` | Skip running `collectplugins` after restart |
| `-NoVerify` | Skip the post-deploy health check |

### 5. Verify

If `url` is set and `-NoVerify` was not used, the script retries `<url>/api/system/health/` for up to 60 seconds. A 200 response is reported as healthy.

### 6. Manual checks in the InvenTree UI

- Open the server URL.
- Navigate to **Admin > Plugins** and confirm the plugin is active and reports the expected version.
- Open a part with a BOM and confirm the plugin panel loads without console errors.

---

## Common pitfalls

- **Missing or outdated `config\servers.json`.** The script exits immediately if the file or server entry is missing.
- **Wrong Docker Compose command.** Older servers use `docker-compose`; newer ones use `docker compose`. Set `docker_command` explicitly or let the script auto-detect.
- **Wrong `service_name`.** Some installs name the container `inventree`, `server`, or `inventree-server`. Check the remote `compose.yaml` if the restart step fails.
- **Wrong data path.** If the wheel upload succeeds but `pip install` inside the container cannot see the file, `data_dir` or `container_data_path` do not match the volume mount.
- **SSH key permissions or agent.** Windows OpenSSH requires the private key file to have restricted permissions and may need `ssh-agent` loaded. The script supports key auth only; password auth is not automated.
- **Local deployment not implemented.** For a local install, run `pip install --upgrade <wheel>` and restart the InvenTree service manually.

---

## Safety rules

1. Always deploy to `staging` first.
2. Only deploy to `production` after the staging deployment has been manually tested in the UI.
3. If the deploy fails at any step (upload, install, restart, collect, health check), stop and fix the issue before retrying.
4. Do not run this skill unless the user explicitly requested deployment.
