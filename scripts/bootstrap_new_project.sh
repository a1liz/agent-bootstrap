#!/usr/bin/env bash

set -euo pipefail

usage() {
  echo "usage: $0 <project-dir> [--with-eval-harness] [--with-multi-run] [--with-tmux] [--with-browser-adapter] [--with-docs-dual-format]" >&2
}

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "$script_dir/.." && pwd)"
template_root="$repo_root/templates/core"
modules_root="$repo_root/templates/modules"

target_dir=""
modules=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --with-tmux)
      modules+=("tmux")
      shift
      ;;
    --with-eval-harness)
      modules+=("eval-harness")
      shift
      ;;
    --with-browser-adapter)
      modules+=("browser-adapter")
      shift
      ;;
    --with-multi-run)
      modules+=("multi-run")
      shift
      ;;
    --with-docs-dual-format)
      modules+=("docs-dual-format")
      shift
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    -*)
      echo "unknown option: $1" >&2
      usage
      exit 1
      ;;
    *)
      if [[ -n "$target_dir" ]]; then
        echo "project directory already set: $target_dir" >&2
        usage
        exit 1
      fi
      target_dir="$1"
      shift
      ;;
  esac
done

if [[ -z "$target_dir" ]]; then
  usage
  exit 1
fi

if [[ -e "$target_dir" ]]; then
  echo "target already exists: $target_dir" >&2
  exit 1
fi

mkdir -p "$target_dir"
cp -R "$template_root"/. "$target_dir"/
mkdir -p "$target_dir/src" "$target_dir/tests"

for module in "${modules[@]}"; do
  cp -R "$modules_root/$module"/. "$target_dir"/
done

bootstrap_source="agent-bootstrap"
bootstrap_version="$(git -C "$repo_root" rev-parse --short HEAD 2>/dev/null || echo "uncommitted")"
project_name="$(basename "$target_dir")"

mv "$target_dir/README.md.tpl" "$target_dir/README.md"

module_list="none"
if [[ ${#modules[@]} -gt 0 ]]; then
  module_list="$(printf '%s\n' "${modules[@]}")"
fi

python3 - "$target_dir" "$project_name" "$bootstrap_source" "$bootstrap_version" "$module_list" <<'PY'
import pathlib
import sys

target_dir = pathlib.Path(sys.argv[1])
project_name = sys.argv[2]
bootstrap_source = sys.argv[3]
bootstrap_version = sys.argv[4]
modules_raw = sys.argv[5]
enabled_modules = []
for line in modules_raw.splitlines():
    if line and line not in enabled_modules:
        enabled_modules.append(line)

replacements = {
    "{{PROJECT_NAME}}": project_name,
    "{{BOOTSTRAP_SOURCE}}": bootstrap_source,
    "{{BOOTSTRAP_VERSION}}": bootstrap_version,
}

for rel_path in [
    "README.md",
    "docs/BOOTSTRAP_ADOPTION.md",
    "docs/md/OVERVIEW.md",
    "docs/md/ARCHITECTURE.md",
    "docs/md/USAGE.md",
    "docs/md/DESIGN_DECISIONS.md",
    "docs/html/index.html",
    "docs/html/architecture.html",
    "docs/html/usage.html",
    "docs/html/design-decisions.html",
]:
    path = target_dir / rel_path
    if not path.exists():
        continue
    text = path.read_text()
    for old, new in replacements.items():
        text = text.replace(old, new)
    path.write_text(text)

adoption_path = target_dir / "docs/BOOTSTRAP_ADOPTION.md"
adoption_text = adoption_path.read_text()
if enabled_modules != ["none"]:
    lines = adoption_text.splitlines()
    new_lines = []
    in_modules = False
    replaced = False
    for line in lines:
        if line == "## Enabled Modules":
            in_modules = True
            new_lines.append(line)
            new_lines.append("")
            for module in enabled_modules:
                new_lines.append(f"- {module}")
            new_lines.append("")
            replaced = True
            continue
        if in_modules:
            if line.startswith("## "):
                in_modules = False
                new_lines.append(line)
            elif line.startswith("- "):
                continue
            elif line == "":
                continue
            else:
                continue
        else:
            new_lines.append(line)
    if replaced:
        adoption_path.write_text("\n".join(new_lines) + "\n")
PY

echo "bootstrapped project at $target_dir"
