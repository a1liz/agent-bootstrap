#!/usr/bin/env bash

set -euo pipefail

usage() {
  echo "usage: $0 [<project-dir>] [--with-<module> ...]" >&2
  echo ""
  echo "Interactive mode (default):" >&2
  echo "  Prompts for project directory and lets you pick modules." >&2
  echo ""
  echo "Non-interactive:" >&2
  echo "  $0 <project-dir> [--with-tmux] [--with-eval-harness] [--with-browser-adapter]" >&2
  echo "                [--with-multi-run] [--with-docs-dual-format]" >&2
}

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "$script_dir/.." && pwd)"
template_root="$repo_root/templates/core"
modules_root="$repo_root/templates/modules"

. "$script_dir/lib.sh"

target_dir=""
modules=()
interactive=true

while [[ $# -gt 0 ]]; do
  case "$1" in
    --with-bootstrap-core)
      interactive=false; shift ;;  # always included, flag kept for compat
    --with-tmux)
      modules+=("tmux"); interactive=false; shift ;;
    --with-eval-harness)
      modules+=("eval-harness"); interactive=false; shift ;;
    --with-browser-adapter)
      modules+=("browser-adapter"); interactive=false; shift ;;
    --with-multi-run)
      modules+=("multi-run"); interactive=false; shift ;;
    --with-docs-dual-format)
      modules+=("docs-dual-format"); interactive=false; shift ;;
    --help|-h)
      usage; exit 0 ;;
    -*)
      echo "unknown option: $1" >&2; usage; exit 1 ;;
    *)
      if [[ -n "$target_dir" ]]; then
        echo "project directory already set: $target_dir" >&2
        usage; exit 1
      fi
      target_dir="$1"; shift ;;
  esac
done

# ── resolve target directory ────────────────────────────────────

if [[ -z "$target_dir" ]]; then
  read -r -p "New project directory: " target_dir
  target_dir="${target_dir/#\~/$HOME}"
fi

if [[ -z "$target_dir" ]]; then
  echo "no project directory given" >&2
  exit 1
fi

if [[ -e "$target_dir" ]]; then
  echo "target already exists: $target_dir" >&2
  exit 1
fi

target_parent="$(dirname "$target_dir")"
if [[ ! -d "$target_parent" ]]; then
  echo "parent directory does not exist: $target_parent" >&2
  exit 1
fi

# ── interactive module selection ────────────────────────────────

if $interactive; then
  all_modules=()
  for d in "$modules_root"/*/; do
    name=$(basename "$d")
    # bootstrap-core is mandatory — don't show in the picker
    [[ "$name" == "bootstrap-core" ]] && continue
    all_modules+=("$name")
  done

  echo ""
  echo "═══ agent-bootstrap: new project ═══"
  echo "Target: $target_dir"
  echo ""
  echo "Available modules:"
  print_module_menu all_modules

  prompt_module_selection "select"
  modules=("${SELECTED_MODULES[@]}")
fi

# bootstrap-core is always included during bootstrap
modules=("bootstrap-core" "${modules[@]}")

# ── confirm ─────────────────────────────────────────────────────

echo ""
echo "About to create:"
echo "  directory: $target_dir"
echo "  project name: $(basename "$target_dir")"
if [[ ${#modules[@]} -eq 0 ]]; then
  echo "  modules: (none)"
else
  echo "  modules: ${modules[*]}"
fi

echo ""
read -r -p "Proceed? [Y/n] " confirm
if [[ -n "$confirm" ]] && [[ "$confirm" != "y" ]] && [[ "$confirm" != "Y" ]] && [[ "$confirm" != "yes" ]]; then
  echo "cancelled"
  exit 0
fi

echo ""

# ── create project ──────────────────────────────────────────────

mkdir -p "$target_dir"
cp -R "$template_root"/. "$target_dir"/
mkdir -p "$target_dir/src" "$target_dir/tests"

for module in "${modules[@]}"; do
  cp -R "$modules_root/$module"/. "$target_dir"/
done

# ── install skills to .claude/skills/ ──────────────────────────
# Module cp -R drops skill.md in the project root (last one wins).
# Move each module's skill.md to .claude/skills/<module>.md and
# clean up stray non-asset files from project root.

bootstrap_source="agent-bootstrap"
bootstrap_version="$(git -C "$repo_root" rev-parse --short HEAD 2>/dev/null || echo "uncommitted")"

skills_dir="$target_dir/.claude/skills"
mkdir -p "$skills_dir"

for module in "${modules[@]}"; do
  module_path="$modules_root/$module"
  module_version=$(git -C "$repo_root" log -1 --format=%h -- "$module_path" 2>/dev/null)
  module_version="${module_version:-unknown}"
  cp "$module_path/skill.md" "$skills_dir/${module}.md"
  sed -i "s/{{BOOTSTRAP_VERSION}}/${module_version}/" "$skills_dir/${module}.md"

  # Supporting assets (same logic as update script)
  dest="$skills_dir/$module"
  mkdir -p "$dest"
  if [[ "$module" == "docs-dual-format" ]]; then
    rsync -a --exclude='README.md' --exclude='skill.md' "$module_path/" "$dest/"
  else
    rsync -a --exclude='README.md' --exclude='skill.md' --exclude='docs/' "$module_path/" "$dest/"
  fi
done

# Remove stray module files that cp -R dropped in project root
rm -f "$target_dir/skill.md" "$target_dir/README.md"

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

modules_display = ", ".join(enabled_modules) if enabled_modules != ["none"] else "none"

replacements = {
    "{{PROJECT_NAME}}": project_name,
    "{{BOOTSTRAP_SOURCE}}": bootstrap_source,
    "{{BOOTSTRAP_VERSION}}": bootstrap_version,
    "{{BOOTSTRAP_MODULES}}": modules_display,
}

for rel_path in [
    "README.md",
    "docs/md/BOOTSTRAP_ADOPTION.md",
    "docs/md/OPERATIONS.md",
    "docs/md/OVERVIEW.md",
    "docs/md/ARCHITECTURE.md",
    "docs/md/USAGE.md",
    "docs/md/DESIGN_DECISIONS.md",
    "docs/html/index.html",
    "docs/html/architecture.html",
    "docs/html/usage.html",
    "docs/html/design-decisions.html",
    "docs/html/bootstrap-adoption.html",
    "docs/html/operations.html",
]:
    path = target_dir / rel_path
    if not path.exists():
        continue
    text = path.read_text()
    for old, new in replacements.items():
        text = text.replace(old, new)
    path.write_text(text)

adoption_path = target_dir / "docs/md/BOOTSTRAP_ADOPTION.md"
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

echo ""
echo "bootstrapped project at $target_dir"
