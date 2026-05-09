#!/usr/bin/env bash

set -euo pipefail

usage() {
  echo "usage: $0 <project-dir> [--with-<module> ...] [--dry-run]" >&2
  echo "  modules: docs-dual-format, eval-harness, multi-run, tmux, browser-adapter" >&2
}

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "$script_dir/.." && pwd)"
modules_root="$repo_root/templates/modules"

target_dir=""
modules=()
dry_run=false

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
    --dry-run)
      dry_run=true
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

if [[ ! -d "$target_dir" ]]; then
  echo "target directory does not exist: $target_dir" >&2
  exit 1
fi

if [[ ${#modules[@]} -eq 0 ]]; then
  echo "no modules specified, nothing to update" >&2
  usage
  exit 1
fi

adoption_doc="$target_dir/docs/BOOTSTRAP_ADOPTION.md"
is_bootstrapped=false
if [[ -f "$adoption_doc" ]]; then
  is_bootstrapped=true
fi

already_enabled=()
if $is_bootstrapped; then
  for module in "${modules[@]}"; do
    if grep -q "^\\- ${module}$" "$adoption_doc" 2>/dev/null; then
      already_enabled+=("$module")
    fi
  done
fi

new_modules=()
for module in "${modules[@]}"; do
  skip=false
  for enabled in "${already_enabled[@]}"; do
    if [[ "$module" == "$enabled" ]]; then
      skip=true
      break
    fi
  done
  if ! $skip; then
    new_modules+=("$module")
  fi
done

if [[ ${#already_enabled[@]} -gt 0 ]]; then
  echo "skipping already-enabled modules: ${already_enabled[*]}" >&2
fi

if [[ ${#new_modules[@]} -eq 0 ]]; then
  echo "all requested modules are already enabled, nothing to do"
  exit 0
fi

bootstrap_version="$(git -C "$repo_root" rev-parse --short HEAD 2>/dev/null || echo "uncommitted")"

echo "updating $target_dir with modules: ${new_modules[*]}"
echo "bootstrap version: $bootstrap_version"

if $is_bootstrapped; then
  echo "mode: merge (bootstrapped project)"
else
  echo "mode: isolate (non-bootstrapped project)"
fi

if $dry_run; then
  echo "[dry-run] would copy these modules:"
  for module in "${new_modules[@]}"; do
    if $is_bootstrapped; then
      echo "  - $module → merge into project root"
    else
      echo "  - $module → .bootstrap/modules/$module/"
    fi
  done
  exit 0
fi

# ── copy modules ──────────────────────────────────────────────

for module in "${new_modules[@]}"; do
  module_path="$modules_root/$module"
  if [[ ! -d "$module_path" ]]; then
    echo "module not found: $module" >&2
    exit 1
  fi

  if $is_bootstrapped; then
    cp -R "$module_path"/. "$target_dir"/
    echo "  copied $module → project root"
  else
    dest="$target_dir/.bootstrap/modules/$module"
    mkdir -p "$dest"
    cp -R "$module_path"/* "$dest"/
    echo "  copied $module → .bootstrap/modules/$module/"
  fi
done

# ── update adoption record (bootstrapped only) ─────────────────

if $is_bootstrapped; then
  python3 - "$target_dir" "$bootstrap_version" "${new_modules[@]}" <<'PY'
import pathlib
import sys

target_dir = pathlib.Path(sys.argv[1])
bootstrap_version = sys.argv[2]
new_modules = sys.argv[3:]

adoption_path = target_dir / "docs" / "BOOTSTRAP_ADOPTION.md"
text = adoption_path.read_text()

text = text.replace(
    "- repo: {{BOOTSTRAP_SOURCE}}",
    "- repo: agent-bootstrap"
)
text = text.replace(
    "- version: {{BOOTSTRAP_VERSION}}",
    f"- version: {bootstrap_version} (updated)"
)

lines = text.splitlines()
new_lines = []
in_modules = False
current_modules = set()

for line in lines:
    if line == "## Enabled Modules":
        in_modules = True
        new_lines.append(line)
        new_lines.append("")
        for old_line in lines[lines.index(line) + 1:]:
            stripped = old_line.strip()
            if stripped.startswith("- "):
                mod = stripped[2:]
                if mod != "none":
                    current_modules.add(mod)
            elif old_line.startswith("## "):
                break
        for mod in sorted(current_modules):
            new_lines.append(f"- {mod}")
        for mod in new_modules:
            if mod not in current_modules:
                new_lines.append(f"- {mod}")
                current_modules.add(mod)
        new_lines.append("")
        continue
    if in_modules:
        if line.startswith("## "):
            in_modules = False
            new_lines.append(line)
        continue
    else:
        new_lines.append(line)

adoption_path.write_text("\n".join(new_lines) + "\n")

readme_tpl = target_dir / "README.md.tpl"
readme = target_dir / "README.md"
if readme_tpl.exists():
    pass
elif readme.exists():
    readme_text = readme.read_text()
    for old, new in {"{{PROJECT_NAME}}": target_dir.name}.items():
        readme_text = readme_text.replace(old, new)
    readme.write_text(readme_text)
PY

  echo ""
  echo "update complete"
  echo "modules now enabled:"
  grep "^\\- " "$adoption_doc" | sed 's/^/  /'
else
  # ── record bootstrap source in .bootstrap/ ──────────────────
  cat > "$target_dir/.bootstrap/source.txt" <<EOF
repo: agent-bootstrap
version: $bootstrap_version
installed: $(date -u +%Y-%m-%dT%H:%M:%SZ)
modules: ${new_modules[*]}
EOF

  echo ""
  echo "update complete — modules placed in .bootstrap/modules/"
  echo ""
  echo "integration hints:"
  for module in "${new_modules[@]}"; do
    case "$module" in
      docs-dual-format)
        echo "  docs-dual-format:"
        echo "    start doc server:  python3 -m http.server 8080 -d .bootstrap/modules/docs-dual-format/docs/html/"
        echo "    symlink to root:   ln -s .bootstrap/modules/docs-dual-format/docs docs"
        ;;
      *)
        echo "  $module: see .bootstrap/modules/$module/README.md"
        ;;
    esac
  done
fi
