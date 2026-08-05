---
name: improve-inventree-plugin
description: Change an InvenTree plugin when the user or another skill wants to modify, extend, or fix behavior and verify it with the deterministic test chain.
---

# Change an InvenTree plugin

**Purpose:** Run a tight change → test → build → commit loop for an existing InvenTree plugin.

---

## One-liner

```bash
bash scripts/run-test-all.sh /workspace/plugins/<plugin-name>
```

---

## Workflow

### 1. Understand the change

Ask the user:

- What behavior should change?
- Which files/components are affected?
- What is the expected result?
- Are there breaking changes or new dependencies?

**Completion criterion:** the change is scoped enough to identify the plugin and the files to touch.

### 2. Locate the plugin and module

```bash
ls /workspace/plugins/<plugin-name>
dirname $(ls /workspace/plugins/<plugin-name>/*/__init__.py | head -1)
```

**Completion criterion:** the plugin directory and Python module name are known.

### 3. Establish a baseline

Run the deterministic test suite before making changes:

```bash
bash scripts/run-test-all.sh /workspace/plugins/<plugin-name>
```

`run-test-all.sh` starts the InvenTree server if it is not already healthy.

**Completion criterion:** baseline results are captured. If the environment is broken, fix it before changing code.

### 4. Make the change

Edit the relevant backend and/or frontend files. Keep the change small and focused.

**Completion criterion:** the requested change is implemented.

### 5. Verify the change

Re-run the deterministic test suite:

```bash
bash scripts/run-test-all.sh /workspace/plugins/<plugin-name>
```

You can use `FAST=1` for a quick lint/unit pass during iteration, but do not call the change done until the full suite passes.

**Completion criterion:** the test layers that should pass are green.

### 6. Build the package

Run the devcontainer build script:

```bash
bash scripts/build-plugin.sh /workspace/plugins/<plugin-name>
```

**Completion criterion:** `dist/*.whl` exists and `build-plugin.sh` exits 0.

### 7. Deploy if requested

If the user wants to test on staging, use the `deploy-inventree-plugin` skill.

**Completion criterion:** staging is requested and passed to the deploy skill, or deployment is skipped.

### 8. Document and commit

Update `README.md` for user-facing changes, `docs/adr/` for non-obvious decisions, and `CHANGELOG.md` if it exists. Then ask the user to review the diff. With approval, commit following `AGENTS.md` git rules — one git command per `Exec` call and an inline commit message.

**Completion criterion:** the diff is committed with user approval, or the user declines and the change is left uncommitted.

---

## Change verification loop

For each meaningful change:

1. Make the change.
2. Run `bash scripts/run-test-all.sh /workspace/plugins/<plugin-name>`.
3. Fix failures and repeat from 2.
4. Build with `bash scripts/build-plugin.sh /workspace/plugins/<plugin-name>`.
5. Document.
6. Commit.

---

## Speed and scope controls

Pass these inside the `run-test-all.sh` command string:

| Flag | Effect |
|------|--------|
| `FAST=1` | Skip integration and E2E tests. |
| `SKIP_LINT=1` | Skip code-quality checks. |
| `SKIP_UNIT=1` | Skip Python unit tests. |
| `SKIP_INTEGRATION=1` | Skip Python integration tests. |
| `SKIP_FRONTEND=1` | Skip all frontend steps. |
| `SKIP_E2E=1` | Skip Playwright E2E (build still runs). |

Example:

```bash
FAST=1 bash scripts/run-test-all.sh /workspace/plugins/<plugin-name>
```

---

## Common pitfalls

- **Skipping the baseline.** Always run `run-test-all.sh` before changing code so you know the environment is healthy.
- **Running the wrong test command.** `test-all.sh` is per-plugin and lives inside the plugin directory. `run-test-all.sh` is at the toolkit root and handles the server.
- **Building on the host.** `build-plugin.sh` must run inside the devcontainer because `node_modules` live on a named Docker volume.
- **Auto-committing.** Do not commit without the user reviewing the diff first.
- **Forgetting documentation.** Non-obvious changes need `docs/adr/` or `README.md` updates.

---

## Related skills

- `test-inventree-plugin` — full details on running and interpreting the deterministic test chain.
- `build-inventree-plugin` — full details on building the wheel and frontend bundle.
- `deploy-inventree-plugin` — deploy a built wheel to staging or production.
