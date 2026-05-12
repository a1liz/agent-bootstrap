#!/usr/bin/env bash
# Shared helpers for agent-bootstrap scripts.
# Source this file: . "$script_dir/lib.sh"

# Parse the description from a skill.md YAML frontmatter.
skill_description() {
  sed -n '/^---$/,/^---$/p' "$1" | sed -n 's/^description: //p' | head -1
}

# Print a numbered menu from a list of module names.
# $1 = array of module names (by nameref)
# Output goes to stderr so it doesn't mix with return values.
# Sets global array MENU_MODULES.
print_module_menu() {
  local -n _modules=$1
  MENU_MODULES=()
  local i=1
  for module in "${_modules[@]}"; do
    MENU_MODULES+=("$module")
    local desc
    desc=$(skill_description "$modules_root/$module/skill.md" 2>/dev/null || echo "(no description)")
    echo "  $i. $module — $desc" >&2
    ((i++))
  done
}

# Print a numbered menu with install status.
# $1 = array of module names (by nameref)
# $2 = associative array module→status (by nameref)
#      status: "current" / "outdated" / "" (not installed)
print_module_menu_with_status() {
  local -n _modules2=$1
  local -n _statuses=$2
  MENU_MODULES=()
  local i=1
  for module in "${_modules2[@]}"; do
    MENU_MODULES+=("$module")
    local desc
    desc=$(skill_description "$modules_root/$module/skill.md" 2>/dev/null || echo "(no description)")
    local s="${_statuses[$module]:-}"
    local mark
    case "$s" in
      current)  mark="[✓]" ;;
      outdated) mark="[!]" ;;
      *)        mark="[ ]" ;;
    esac
    echo "  $i. $mark $module — $desc" >&2
    ((i++))
  done
}

# Copy the skill file to <name>/SKILL.md so Claude Code native discovers it
# alongside the flat .md file that OMC uses.
# $1 = target project root dir
# $2 = module name (e.g. "tmux")
create_native_command() {
  local target_dir="$1"
  local module_name="$2"
  local skills_dir="$target_dir/.claude/skills"
  local skill_file="$skills_dir/${module_name}.md"
  local skill_dir="$skills_dir/$module_name"

  # Claude Code native loads skills from .claude/skills/<name>/SKILL.md
  mkdir -p "$skill_dir"
  cp "$skill_file" "$skill_dir/SKILL.md"
}

# Prompt user to pick modules from the menu (uses MENU_MODULES from print_*).
# $1 = "select" (new install) or "update" (add/update existing)
# Returns selected module names in global array SELECTED_MODULES.
prompt_module_selection() {
  local mode="$1"
  local prompt
  if [[ "$mode" == "select" ]]; then
    prompt="Enter numbers to include (comma-separated), 'all', 'sync', or press Enter for none"
  else
    prompt="Enter numbers to install/update (comma-separated), 'all', 'sync', or press Enter to skip"
  fi

  SELECTED_MODULES=()
  echo "" >&2
  read -r -p "$prompt: " answer

  if [[ -z "$answer" ]]; then
    return
  fi

  if [[ "$answer" == "sync" ]]; then
    SELECTED_MODULES=("__sync_native__")
    return
  fi

  if [[ "$answer" == "all" ]]; then
    SELECTED_MODULES=("${MENU_MODULES[@]}")
    return
  fi

  IFS=',' read -ra picks <<< "$answer"
  for pick in "${picks[@]}"; do
    pick=$(echo "$pick" | xargs)
    local n=${#MENU_MODULES[@]}
    if [[ "$pick" =~ ^[0-9]+$ ]] && (( pick >= 1 && pick <= n )); then
      SELECTED_MODULES+=("${MENU_MODULES[$((pick - 1))]}")
    fi
  done
}
