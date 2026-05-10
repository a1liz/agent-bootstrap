---
name: docs-dual-format
description: Maintain project documentation in parallel markdown and HTML formats with shared style and navigation. Use when creating new docs, updating existing docs, or when the user asks about documentation standards.
version: {{BOOTSTRAP_VERSION}}
---

# Dual-Format Documentation

All project documentation in `docs/` must be maintained in two parallel formats:

| Format | Location | Purpose |
|--------|----------|---------|
| Markdown | `docs/md/` | CLI-friendly, version-control diffable |
| HTML | `docs/html/` | Browser-friendly, styled with shared CSS |

## Rules

1. **Content parity**: Every `.md` file in `docs/md/` must have a corresponding `.html` file in `docs/html/` with equivalent information.
2. **Shared style**: All HTML pages reference the same `style.css` from `docs/html/style.css`.
3. **Consistent navigation**: All HTML pages share the same `<nav>` with current-page highlighting.
4. **README documents serving**: The project README must include instructions for starting the doc server and SSH tunnel.
5. **No placeholder text**: After completion, no `docs/md/*.md` file may contain template placeholder text (e.g., "补充…", "待定义", "模块 A"). Every claim must be derived from actual repo analysis.

## Page structure

### Minimum baseline (mandatory for every project)

These four pages must exist after initialization. They cover the essential dimensions of any project:

| Page | File | Covers |
|------|------|--------|
| Overview | `OVERVIEW.md` | Project purpose, core metrics, current status, quick nav |
| Architecture | `ARCHITECTURE.md` | Directory tree, module responsibilities, data flow, key schemas |
| Usage | `USAGE.md` | Build / run / test commands, configuration, environment setup |
| Design Decisions | `DESIGN_DECISIONS.md` | Key ADRs, why-not alternatives, tradeoffs made |

### Adding pages beyond the baseline

The four core pages are a **floor, not a ceiling**. After analyzing the repo, add pages when the content warrants independent treatment. Use these heuristics to decide:

- **Independent subsystem or service** — if the repo contains multiple deployable units, each deserves its own architecture-style page
- **Non-trivial API contract or data schema** — if a reader would need to consult this regularly, give it a dedicated page
- **Multiple deployment environments** — if setup varies significantly across dev / staging / prod, split them
- **Contribution guide or testing strategy** — if these are substantial enough to be referenced independently

Counter-constraint: do NOT split for the sake of splitting, and do NOT cram unrelated topics into one giant page. The test: each page should be explainable to a new teammate as "this is the page about X."

When adding a page:
1. Create `docs/md/<SLUG>.md` with the content
2. Create `docs/html/<slug>.html` reusing the shared `<nav>` and CSS
3. Add the new page to the `<nav>` in every existing HTML page
4. Update the TOC in `docs/html/index.html`

## Workflow

This is a two-phase process. Phase 1 must complete before Phase 2 begins.

### Phase 1: Analyze the repo and fill docs/md/

Before writing any documentation, gather information from the actual repository:

1. **Read existing documentation sources** — `README.md`, `CLAUDE.md`, `AGENTS.md`, `.omc/` files, any existing `docs/` content
2. **Read manifest files** — `package.json`, `Cargo.toml`, `pyproject.toml`, `go.mod`, `Makefile`, or equivalent
3. **Map the directory tree** — identify top-level modules, their responsibilities, and how they connect
4. **Extract commands** — build, test, run, lint, deploy — from scripts, Makefile targets, CI configs, or manifest scripts
5. **Extract design rationale** — from `git log` for major architectural commits, ADR files, or CLAUDE.md context

Then produce or update `docs/md/`:

- Start with the four core files (OVERVIEW, ARCHITECTURE, USAGE, DESIGN_DECISIONS)
- Add supplementary `.md` files for any topic that meets the heuristics above
- Every file must contain concrete, repo-specific information — no placeholder text may survive

### Phase 2: Convert docs/md/ to docs/html/

For each `.md` file in `docs/md/`, generate or update the corresponding `.html` file in `docs/html/`:

1. Use the existing HTML pages as a style reference — same `<nav>`, same `<head>` structure, same CSS class vocabulary
2. Convert Markdown content to HTML, preserving headings, code blocks, tables, lists, and links
3. Ensure the `<nav>` in every HTML file lists all current pages with correct `class="active"` on the current page
4. Update `docs/html/index.html` to include the full table of contents

## Serving docs

```bash
python3 -m http.server 8080 -d docs/html/
```

SSH tunnel from local machine:
```bash
ssh -L 8080:127.0.0.1:8080 -N user@<server>
```

## Verification checklist

Before claiming completion, verify:

- [ ] Every `.md` file has a corresponding `.html` file
- [ ] No placeholder text remains in any `docs/md/*.md` file
- [ ] All HTML pages share the same `<nav>` with correct active-page highlighting
- [ ] All HTML pages reference `style.css`
- [ ] Cross-page links work (both in MD and HTML)
- [ ] `index.html` TOC lists every page
- [ ] README includes doc serving instructions
