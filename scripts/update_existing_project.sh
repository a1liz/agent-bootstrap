#!/usr/bin/env bash

set -euo pipefail

usage() {
  echo "usage: $0 [<project-dir>] [--dry-run]" >&2
  echo ""
  echo "Interactive mode (default):" >&2
  echo "  Prompts for project directory, detects current state, and lets you pick skills." >&2
  echo ""
  echo "Non-interactive:" >&2
  echo "  $0 <project-dir> --with-<skill> [...]" >&2
  echo "  skills: bootstrap-core, eval-harness, multi-run, tmux, browser-adapter, docs-dual-format" >&2
}

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "$script_dir/.." && pwd)"
modules_root="$repo_root/templates/modules"

. "$script_dir/lib.sh"

target_dir=""
modules=()
dry_run=false
interactive=true

while [[ $# -gt 0 ]]; do
  case "$1" in
    --with-bootstrap-core)
      modules+=("bootstrap-core"); interactive=false; shift ;;
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
    --dry-run)
      dry_run=true; shift ;;
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
  read -r -p "Target project directory: " target_dir
  target_dir="${target_dir/#\~/$HOME}"
fi

if [[ -z "$target_dir" ]] || [[ ! -d "$target_dir" ]]; then
  echo "target directory does not exist: ${target_dir:-"(empty)"}" >&2
  exit 1
fi

target_dir="$(cd "$target_dir" && pwd)"

# ── detect current state ────────────────────────────────────────

bootstrap_version="$(git -C "$repo_root" rev-parse --short HEAD 2>/dev/null || echo "uncommitted")"

skills_dir="$target_dir/.claude/skills"

adoption_file=""
for candidate in "$target_dir/docs/md/BOOTSTRAP_ADOPTION.md" "$target_dir/docs/BOOTSTRAP_ADOPTION.md"; do
  if [[ -f "$candidate" ]]; then
    adoption_file="$candidate"
    break
  fi
done
source_record="$skills_dir/.bootstrap-source.txt"

bootstrapped=false
has_skills=false

if [[ -n "$adoption_file" ]]; then
  bootstrapped=true
fi
if [[ -f "$source_record" ]]; then
  has_skills=true
fi

# List all available modules from template dir
all_modules=()
for d in "$modules_root"/*/; do
  all_modules+=("$(basename "$d")")
done

# Read installed skill versions
installed_skills=()
declare -A installed_versions
if [[ -d "$skills_dir" ]]; then
  for f in "$skills_dir"/*.md; do
    if [[ -f "$f" ]]; then
      _name=$(basename "$f" .md)
      installed_skills+=("$_name")
      installed_versions["$_name"]=$(awk '/^version:/ {print $2; exit}' "$f")
    fi
  done
fi

# Compare installed versions against latest from module git history
declare -A latest_versions skill_status
for module in "${all_modules[@]}"; do
  _v=$(git -C "$repo_root" log -1 --format=%h -- "$modules_root/$module" 2>/dev/null)
  latest_versions["$module"]="${_v:-unknown}"
done

outdated_count=0
for module in "${all_modules[@]}"; do
  if [[ -n "${installed_versions[$module]:-}" ]]; then
    if [[ "${installed_versions[$module]}" == "${latest_versions[$module]}" ]]; then
      skill_status["$module"]="current"
    else
      skill_status["$module"]="outdated"
      outdated_count=$((outdated_count + 1))
    fi
  else
    skill_status["$module"]=""
  fi
done

local_ver=""
if [[ -f "$source_record" ]]; then
  local_ver=$(grep "^version:" "$source_record" | awk '{print $2}')
fi

echo ""
echo "═══ agent-bootstrap update ═══"
echo "Target: $target_dir"

if $bootstrapped; then
  echo "Status: bootstrapped${local_ver:+ (bootstrap v $local_ver)}"
elif $has_skills; then
  echo "Status: skills only${local_ver:+ (v $local_ver)} — no bootstrap scaffolding"
else
  echo "Status: clean — no bootstrap or skills detected"
fi

echo ""
echo "Currently installed skills:"
if [[ ${#installed_skills[@]} -eq 0 ]]; then
  echo "  (none)"
else
  for s in "${installed_skills[@]}"; do
    local_v="${installed_versions[$s]:-?}"
    local_status=""
    if [[ "${skill_status[$s]:-}" == "outdated" ]]; then
      local_status=" (v $local_v → ${latest_versions[$s]})"
    else
      local_status=" (v $local_v)"
    fi
    echo "  - $s$local_status"
  done
fi

if [[ $outdated_count -gt 0 ]]; then
  echo ""
  echo "⚠  $outdated_count skill(s) are outdated and should be updated."
fi

echo ""
echo "Available skills:"
print_module_menu_with_status all_modules skill_status

# ── interactive selection ───────────────────────────────────────

if $interactive; then
  prompt_module_selection "update"
  modules=("${SELECTED_MODULES[@]}")
fi

if [[ ${#modules[@]} -eq 0 ]]; then
  echo ""
  echo "no skills selected, nothing to do"
  exit 0
fi

# Check which are already installed vs new
new_modules=()
update_modules=()
for module in "${modules[@]}"; do
  if [[ -n "${skill_status[$module]:-}" ]]; then
    update_modules+=("$module")
  else
    new_modules+=("$module")
  fi
done

if [[ ${#update_modules[@]} -gt 0 ]]; then
  echo ""
  echo "will update: ${update_modules[*]}"
fi
if [[ ${#new_modules[@]} -gt 0 ]]; then
  echo "will install: ${new_modules[*]}"
fi

if $interactive; then
  echo ""
  read -r -p "Proceed? [Y/n] " confirm
  if [[ -n "$confirm" ]] && [[ "$confirm" != "y" ]] && [[ "$confirm" != "Y" ]] && [[ "$confirm" != "yes" ]]; then
    echo "cancelled"
    exit 0
  fi
fi

if $dry_run; then
  echo "[dry-run] would copy:"
  for module in "${modules[@]}"; do
    echo "  - $module → .claude/skills/${module}.md"
  done
  exit 0
fi

# ── copy skills ─────────────────────────────────────────────────

mkdir -p "$skills_dir"

for module in "${modules[@]}"; do
  module_path="$modules_root/$module"
  if [[ ! -d "$module_path" ]]; then
    echo "module not found: $module" >&2
    exit 1
  fi

  # Copy the skill file and stamp module-specific version
  module_version=$(git -C "$repo_root" log -1 --format=%h -- "$module_path" 2>/dev/null)
  module_version="${module_version:-unknown}"
  cp "$module_path/skill.md" "$skills_dir/${module}.md"
  sed -i "s/{{BOOTSTRAP_VERSION}}/${module_version}/" "$skills_dir/${module}.md"
  echo "  skill: .claude/skills/${module}.md  (v ${module_version})"

  # Copy supporting assets
  dest="$skills_dir/$module"
  rm -rf "$dest"
  mkdir -p "$dest"

  if [[ "$module" == "docs-dual-format" ]]; then
    rsync -av --exclude='README.md' --exclude='skill.md' "$module_path/" "$dest/" | tail -1
  else
    rsync -av --exclude='README.md' --exclude='skill.md' --exclude='docs/' "$module_path/" "$dest/" | tail -1
  fi
done

# ── record source ───────────────────────────────────────────────

cat > "$skills_dir/.bootstrap-source.txt" <<EOF
repo: agent-bootstrap
version: $bootstrap_version
updated: $(date -u +%Y-%m-%dT%H:%M:%SZ)
modules: ${modules[*]}
EOF

echo ""
echo "done — skills in .claude/skills/"
