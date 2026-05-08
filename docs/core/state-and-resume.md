# State And Resume

Resumable pipelines are only trustworthy when state files match actual progress.

## Rules

- Persist phase, generation, and chunk progress as part of normal execution, not only at startup or shutdown.
- Do not reinitialize state on resume paths.
- Keep convergence state separate from phase state.
- Keep runtime configuration snapshots in the workspace so evaluators can resolve context without hidden assumptions.
- Make resume behavior explicit in CLI logs.

## Minimum State Files

- `phase_state.json`
- `convergence_state.json`
- `traces_config.json`

## State Integrity Principles

- Save state after each completed chunk or equivalent durable milestone.
- Ensure saved counters match generated result files.
- Avoid resume code paths that silently reset state.
- Treat mismatches between saved state and saved results as bugs worth fixing, not as harmless drift.

## Minimum Durable Milestones

State should be written after each durable unit of progress, such as a completed chunk, completed candidate evaluation, or confirmed phase transition.

## Resume Log Requirements

Resume paths should clearly log:

- that a resume is happening
- which saved state files were loaded
- what phase or checkpoint is being resumed
- any mismatch or fallback behavior

## State Mismatch Policy

If saved state and saved outputs disagree, treat the mismatch as a correctness issue. Do not silently reinitialize or continue without surfacing the inconsistency.
