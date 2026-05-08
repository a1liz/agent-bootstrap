# Agent Project Bootstrap

This repository helps you start a new agent-oriented codebase with a usable baseline instead of inventing repository structure, runtime layout, and operator docs from scratch.

If you opened this repo and were mainly trying to answer "how do I actually use it?", the short version is:

1. Bootstrap a new project with `scripts/bootstrap_new_project.sh`.
2. Add only the optional modules you need.
3. Let the generated project own its copied files.

## When To Use This Repo

This bootstrap is useful when your project has one or more of these traits:

- long-running or resumable agent execution
- runtime artifacts, logs, and state that should stay out of source directories
- iterative eval loops
- subprocess orchestration
- operator-facing observability or tmux-driven workflows

If you need product logic, framework setup, or business-domain code, this repo does not provide that. It provides engineering structure only.

## What This Repo Contains

- `templates/core/`: the baseline files copied into every new project
- `templates/modules/`: optional add-on modules
- `scripts/bootstrap_new_project.sh`: creates a new project from the templates
- `scripts/validate_template_integrity.sh`: checks that documented template surfaces still exist
- `docs/`: reference material and adoption guidance
- `examples/minimal-agent-project/`: the expected shape of a minimal generated project

## Quick Start

Create a minimal project:

```bash
scripts/bootstrap_new_project.sh /path/to/my-agent-project
```

Create a project with common optional modules:

```bash
scripts/bootstrap_new_project.sh /path/to/my-agent-project \
  --with-eval-harness \
  --with-multi-run \
  --with-tmux
```

The script will:

- copy `templates/core/` into the target directory
- optionally layer selected module templates on top
- create `src/` and `tests/`
- materialize `README.md` from the template
- record the bootstrap source/version in `docs/BOOTSTRAP_ADOPTION.md`

The target directory must not already exist.

## Which Modules To Enable

Start with only `core`, then add modules based on actual workflow needs:

- `--with-eval-harness`: for explicit eval structure and repeatable evaluation loops
- `--with-multi-run`: for managing multiple runs or run sets
- `--with-tmux`: for operator-friendly long-running execution and monitoring
- `--with-browser-adapter`: specialized browser/tool integration support

Recommended default order if you are unsure:

1. `core`
2. `eval-harness`
3. `multi-run`
4. `tmux`
5. `browser-adapter` only if the project really needs it

## Typical Adoption Flow

1. Read [docs/overview.md](/data/home/liz/agent-bootstrap/docs/overview.md).
2. Bootstrap a new project with `scripts/bootstrap_new_project.sh`.
3. Inspect the generated project, especially `README.md`, `docs/BOOTSTRAP_ADOPTION.md`, and `docs/OPERATIONS.md`.
4. Use [checklists/new-project-checklist.md](/data/home/liz/agent-bootstrap/checklists/new-project-checklist.md) to confirm the baseline is in place.
5. Evolve the copied files inside the new project. Do not treat this repo as a live submodule by default.

## What To Read Next

- [docs/overview.md](/data/home/liz/agent-bootstrap/docs/overview.md): what the bootstrap is trying to standardize
- [docs/adoption-model.md](/data/home/liz/agent-bootstrap/docs/adoption-model.md): how to adopt and own the generated files
- [examples/minimal-agent-project/README.md](/data/home/liz/agent-bootstrap/examples/minimal-agent-project/README.md): minimal generated project shape
- [checklists/new-project-checklist.md](/data/home/liz/agent-bootstrap/checklists/new-project-checklist.md): post-bootstrap verification

## For Maintainers Of This Repo

If you change templates, module coverage, or documented file surfaces, run:

```bash
scripts/validate_template_integrity.sh
```
