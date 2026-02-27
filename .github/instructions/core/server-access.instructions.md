---
applyTo: "config/servers.json,scripts/**,**/*.ps1"
---

# Server Access

All server connection details (SSH, API keys, plugin directories) are stored
in `config/servers.json`. **Always read this file** before constructing any
SSH, SCP, or API command.

## SSH Commands

Use the `key_file` from `servers.json` with the `-i` flag:

```powershell
# Read the config first
$config = Get-Content config/servers.json | ConvertFrom-Json
$ssh = $config.servers.staging.ssh

# Then use it
ssh -i $ssh.key_file "$($ssh.user)@$($ssh.host)" "<command>"
scp -i $ssh.key_file <local_file> "$($ssh.user)@$($ssh.host):<remote_path>"
```

## Deployment

Use the toolkit scripts -- they already read `servers.json` automatically:

```powershell
.\scripts\Deploy-Plugin.ps1 -Plugin "<Name>" -Server staging
```

Only SSH manually when debugging server-side issues the scripts don't cover.
