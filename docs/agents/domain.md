# Domain Docs

How the engineering skills should consume this repo's domain documentation when exploring the codebase.

## Before exploring, read these

- **`CONTEXT.md`** at the repo root for the toolkit container context.
- **`CONTEXT-MAP.md`** at the repo root — it is the canonical map for the multi-context InvenTree plugin toolkit.
- **`docs/reference/inventree-plugins/CONTEXT.md`** when working on a generic InvenTree plugin or tooling that applies to any plugin.
- **`C:\Software Projects\inventree-plugin-ai-toolkit\docs\reference\inventree-bom-build-buy-suite\CONTEXT.md`** (and related suite docs) when working on the Flat BOM, Build Order, or Purchase List plugins.
- **`docs/adr/`** — read ADRs that touch the area you're about to work on. In this repo, system-wide decisions live here; per-plugin decisions live in `plugins/<name>/docs/adr/`.
- If `docs/adr/` does not exist yet, fall back to **`docs/decisions.md`** for the append-only decision log.
- **`reference/README.md`** and the `reference/inventree-source` submodule when you need to look at the InvenTree source code or example plugin implementations as reference.

If any of these files don't exist, **proceed silently**. Don't flag their absence; don't suggest creating them upfront. The `/domain-modeling` skill creates them lazily when terms or decisions actually get resolved.

## File structure

Multi-context repo (presence of `CONTEXT-MAP.md` at the root):

```
/
├── CONTEXT.md                         ← toolkit container context
├── CONTEXT-MAP.md                     ← context map
├── docs/
│   ├── adr/                           ← system-wide decisions (or docs/decisions.md)
│   ├── agents/                        ← agent skill configuration
│   └── reference/
│       ├── inventree-plugins/
│       │   └── CONTEXT.md             ← generic InvenTree plugin context
│       └── inventree-bom-build-buy-suite/
│           ├── VISION.md
│           ├── CONTEXT.md             ← BOM/Build/Buy suite shared domain
│           ├── PLATFORM-REFERENCE.md
│           ├── ARCHITECTURE-DECISIONS.md
│           ├── BOUNDARIES.md
│           └── BUILD-ORDER.md
├── plugins/
│   ├── inventree-flat-bom-generator/
│   │   ├── CONTEXT.md
│   │   └── docs/adr/
│   ├── inventree-build-tree-generator/
│   │   ├── CONTEXT.md
│   │   └── docs/adr/
│   └── inventree-cogs-suite-plugin/
│       ├── CONTEXT.md
│       └── docs/adr/
└── reference/                         ← InvenTree source and plugin-creator submodules
```

## Use the glossary's vocabulary

When your output names a domain concept (in an issue title, a refactor proposal, a hypothesis, a test name), use the term as defined in `CONTEXT.md`, `CONTEXT-MAP.md`, `docs/reference/inventree-plugins/CONTEXT.md`, or the relevant plugin `CONTEXT.md`. Don't drift to synonyms the glossary explicitly avoids.

If the concept you need isn't in the glossary yet, that's a signal — either you're inventing language the project doesn't use (reconsider) or there's a real gap (note it for `/domain-modeling`).

## Flag ADR conflicts

If your output contradicts an existing ADR, surface it explicitly rather than silently overriding:

> _Contradicts ADR-0007 (event-sourced orders) — but worth reopening because…_
