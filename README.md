# Agent Project Bootstrap

## What This Repo Is

This repository is a bootstrap source for new agent projects. It captures reusable engineering rules, starter templates, and minimal automation for projects that are developed by long-running coding agents and need consistent runtime structure, context handling, evaluation discipline, tool integration boundaries, and delivery habits.

## What It Produces

This repository is intended to produce three things:

- core rules that most agent projects should adopt
- optional modules for heavier or more specialized workflows
- starter templates and scripts that generate a new project baseline

## Adoption Model

The recommended adoption model is `scaffold + selective modules + reference docs`.

- Copy the core template into a new project and let that project own it.
- Add optional modules only when the project needs them.
- Keep rationale and broader reference material in this repository instead of copying everything into each project.

This repository is not intended to be consumed as a `submodule` by default.

## Repository Map

- `docs/`: rules, adoption guidance, and reference material
- `templates/`: files copied into new projects
- `scripts/`: bootstrap automation
- `checklists/`: adoption and module selection checklists
- `examples/`: example project shapes generated from the templates

## Core vs Modules vs Reference

- `core`: baseline rules and files that most agent projects should adopt at initialization time
- `modules`: opt-in guidance and templates for heavier workflows
- `reference`: rationale, anti-patterns, and migration notes that stay in the bootstrap repository

## Getting Started

Start with [docs/overview.md](/data/home/liz/agent-bootstrap/docs/overview.md) and [docs/adoption-model.md](/data/home/liz/agent-bootstrap/docs/adoption-model.md). Use `scripts/bootstrap_new_project.sh` to generate a minimal project baseline from `templates/core`, then enable primary modules such as `--with-eval-harness`, `--with-multi-run`, or `--with-tmux` when needed. `browser-adapter` remains available as a more specialized module. Run `scripts/validate_template_integrity.sh` when changing templates or module coverage.
