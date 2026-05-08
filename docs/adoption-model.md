# Adoption Model

## Recommended Approach

The recommended approach is `scaffold + selective modules + reference docs`.

- Generate a local baseline from this repository.
- Copy only the files that the new project must own and evolve.
- Bring in optional modules only when their operating cost is justified.
- Keep broader rationale and organizational guidance in this repository.

## Why Not Submodule-First

Using this repository as a default `submodule` couples project-local templates to a shared upstream in a way that is usually awkward:

- most adopted files need local editing
- projects will diverge at different speeds
- ownership becomes unclear when the same rule exists both locally and upstream
- many documents are useful as references but should not be maintained inside each project

`submodule` can still be reasonable for a read-only standards mirror, but it should not be the default adoption path.

## What Gets Copied

The following content is expected to be copied into a new project:

- minimal repository layout
- runtime workspace baseline
- `.gitignore` baseline
- operations and adoption docs
- state and event schema examples
- minimal validation script
- selected module templates when the project opts into them

In practice, most projects should start by considering `eval-harness`, `multi-run`, and `tmux`. More specialized integrations such as `browser-adapter` should be enabled only when the project shape clearly requires them.

## What Stays Referenced

The following content should usually stay in this repository and be referenced rather than copied wholesale:

- rationale and tradeoff explanations
- anti-patterns and migration notes
- optional modules not adopted by the project
- organization-wide guidance that is not part of project runtime behavior

## Project-Level Ownership

Once the templates are copied, the project owns them. The bootstrap repository is the source of new starting points, not the runtime dependency that every project must continuously track.
