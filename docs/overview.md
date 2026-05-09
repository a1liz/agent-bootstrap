# Overview

## Goal

The goal of this repository is to help a team start a new agent project quickly and keep it structurally consistent as the project evolves. The baseline should make runtime state, observability, state persistence, evaluation isolation, and repository hygiene predictable from day one.

## Target Project Types

This bootstrap is aimed at projects with one or more of these traits:

- long-running or resumable execution
- generated runtime artifacts
- iterative evaluation loops
- subprocess orchestration
- tool-heavy workflows with operator monitoring

## Non-Goals

This repository is not a business-domain starter kit and does not attempt to provide product logic, application frameworks, or stack-specific feature code. It provides engineering structure, not product behavior.

## Bootstrap Layers

- `core`: baseline rules and template files that should usually be copied into a new project
- `modules`: optional capabilities for projects that need heavier evaluation, richer context management, or stricter tool contracts
- `reference`: rationale and migration material that informs the bootstrap but does not need to live inside every adopted project

## Typical Adoption Flow

1. Read the adoption model and core rules.
2. Generate a new project from `templates/core`.
3. Decide whether any optional modules are needed.
4. Record what was adopted in `docs/BOOTSTRAP_ADOPTION.md` inside the new project.
5. Let the new project own its copied templates and evolve them locally.
6. Validate template integrity whenever the bootstrap source changes.

The first supported primary modules are:

- `eval-harness`
- `multi-run`
- `tmux`

The current specialized modules are:

- `browser-adapter`
- `docs-dual-format`

Use `scripts/validate_template_integrity.sh` in this repository to check that documented core and module template surfaces still exist after changes.
