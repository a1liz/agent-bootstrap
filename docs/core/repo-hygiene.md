# Repo Hygiene

Agent-heavy projects drift quickly unless generated and local-only content is clearly separated from versioned content.

## Rules

- Keep secrets such as `.env.local` ignored.
- Ignore runtime workspaces, generated policies, caches, and test scratch directories.
- Version only hand-maintained source policies and intentional exported artifacts.
- Keep commit boundaries thematic and small enough to review.
- Avoid committing temporary debug outputs or build residue.

## Recommended Ignore Patterns

```text
.env.local
.pytest_cache/
__pycache__/
artifacts/runs/
repl/eval_*/
```

## Commit Guidelines

- separate infrastructure changes from behavior changes when possible
- isolate evaluation/runtime cleanup from unrelated feature work
- include tests with the behavior they validate
- avoid mixing source changes with generated runtime outputs

## Review Checklist

- Are runtime artifacts outside the source tree
- Are logs and saved state ignored by git
- Are generated modules excluded from version control
- Do commits reflect coherent engineering steps

## Versioned vs Generated Content

Version only hand-maintained source, intentional documentation, and explicitly exported artifacts. Keep generated runtime content outside the versioned surface by default.

## Minimum Ignore Baseline

Every adopted project should at least ignore local secrets, caches, runtime workspaces, and evaluation scratch directories.

## Review Focus

When reviewing changes in an agent-heavy project, check that source and runtime boundaries remain intact and that generated or local-only content has not leaked into the commit.
