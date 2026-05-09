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

## Serving docs

```bash
python3 -m http.server 8080 -d docs/html/
```

SSH tunnel from local machine:
```bash
ssh -L 8080:127.0.0.1:8080 -N user@<server>
```

## When creating or updating docs

1. Create/edit the `.md` file in `docs/md/` first.
2. Create/update the corresponding `.html` file in `docs/html/`, reusing the shared `<nav>` and `<link rel="stylesheet" href="style.css">`.
3. Update `docs/html/index.html` to link to any new page.
