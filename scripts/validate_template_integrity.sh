#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "$script_dir/.." && pwd)"

fail() {
  echo "template integrity check failed: $1" >&2
  exit 1
}

assert_exists() {
  local path="$1"
  [[ -e "$repo_root/$path" ]] || fail "missing $path"
}

core_required=(
  "templates/core/README.md.tpl"
  "templates/core/.gitignore"
  "templates/core/docs/BOOTSTRAP_ADOPTION.md"
  "templates/core/docs/OPERATIONS.md"
  "templates/core/scripts/validate_repo_structure.sh"
  "templates/core/schemas/events.schema.json"
  "templates/core/schemas/phase_state.example.json"
  "templates/core/schemas/convergence_state.example.json"
  "templates/core/schemas/traces_config.example.json"
)

for path in "${core_required[@]}"; do
  assert_exists "$path"
done

module_names=(
  "tmux"
  "eval-harness"
  "browser-adapter"
  "multi-run"
)

for module in "${module_names[@]}"; do
  assert_exists "templates/modules/$module/README.md"
done

assert_exists "templates/modules/tmux/docs/TMUX_OPERATIONS.md"
assert_exists "templates/modules/tmux/scripts/launch_in_tmux.sh"
assert_exists "templates/modules/eval-harness/docs/EVALS.md"
assert_exists "templates/modules/eval-harness/evals/README.md"
assert_exists "templates/modules/browser-adapter/docs/BROWSER_ADAPTER.md"
assert_exists "templates/modules/browser-adapter/artifacts/browser/.gitkeep"
assert_exists "templates/modules/multi-run/docs/MULTI_RUN.md"
assert_exists "templates/modules/multi-run/reports/.gitkeep"

doc_required=(
  "docs/overview.md"
  "docs/adoption-model.md"
  "docs/core/runtime-layout.md"
  "docs/core/observability.md"
  "docs/core/state-and-resume.md"
  "docs/core/repo-hygiene.md"
  "docs/core/minimal-isolation.md"
  "docs/modules/advanced-eval-isolation.md"
  "docs/modules/context-and-working-agreements.md"
  "docs/modules/tool-integration-contracts.md"
  "docs/modules/delivery-rhythm-and-evals.md"
  "docs/modules/tmux-operations.md"
  "docs/modules/browser-adapter.md"
  "docs/modules/multi-run.md"
)

for path in "${doc_required[@]}"; do
  assert_exists "$path"
done

echo "template integrity looks valid"
