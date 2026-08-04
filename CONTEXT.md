# Context: InvenTree Plugin AI Toolkit

This repository is the **InvenTree Plugin AI Toolkit**. It is a container for developing **InvenTree-based plugins** of any type. Each plugin is an independent git repository under `plugins/`. The toolkit provides shared tooling, documentation, and domain context.

## Scope

The root context covers:

- Toolkit-wide conventions and tooling (devcontainer, `scripts/`, `.agents/skills/`, `AGENTS.md`).
- The `plugins/` directory as a container of independent plugin repositories.
- The relationship between the generic InvenTree plugin context and the BOM/Build/Buy suite special domain.

It does **not** replace:
- The generic InvenTree plugin context.
- The BOM/Build/Buy suite-specific shared domain model.
- The internal implementation details of any individual plugin.

For those, see the shared contexts below and the relevant per-plugin `CONTEXT.md`.

## Shared contexts

- **Generic InvenTree plugin context:** Conventions, mixins, workflow, documentation standards, and tooling that apply to any InvenTree plugin in `plugins/`. Documented in [`docs/reference/inventree-plugins/CONTEXT.md`](./docs/reference/inventree-plugins/CONTEXT.md).
- **BOM/Build/Buy suite (special case):** A planned set of three interrelated plugins (Flat BOM Generator, Build Order Generator, Purchase List Generator) with a tightly coupled shared domain model. Documented in [`docs/reference/inventree-bom-build-buy-suite/`](./docs/reference/inventree-bom-build-buy-suite/).

## Key concepts

- **InvenTree Plugin:** An extension package for InvenTree, hosted as an independent repository under `plugins/`.
- **BOM/Build/Buy suite:** The special shared domain model for Flat BOM Generator, Build Order Generator, and Purchase List Generator.
- **Shared domain language:** Canonical terms and ownership boundaries for the suite, defined in `CONTEXT-MAP.md` and `C:\Software Projects\inventree-plugin-ai-toolkit\docs\reference\inventree-bom-build-buy-suite\`.
- **Devcontainer:** The recommended development environment for consistent tooling and testing.

## Decisions

System-wide architecture and process decisions live in `docs/adr/` (or `docs/decisions.md` until ADRs are created).
