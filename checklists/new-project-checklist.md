# New Project Checklist

- Confirm `docs/BOOTSTRAP_ADOPTION.md` exists and names the adopted core.
- Confirm `docs/OPERATIONS.md` exists and tells operators where to look first.
- Confirm `artifacts/runs/` exists as the runtime workspace root.
- Confirm runtime outputs are not intended to land in versioned source directories.
- Confirm logs and state file locations are documented.
- Confirm `.gitignore` excludes runtime artifacts and local-only state.
- Confirm the bootstrap source version is recorded.
- Confirm whether advanced evaluation isolation is needed.
- Confirm whether context, tool, or delivery modules should be adopted next.
