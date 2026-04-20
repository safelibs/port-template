#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"

fail() {
  printf 'validate-template: %s\n' "$*" >&2
  exit 1
}

require_file() {
  local path="$1"

  [[ -f "$repo_root/$path" ]] || fail "missing required file: $path"
}

require_dir() {
  local path="$1"

  [[ -d "$repo_root/$path" ]] || fail "missing required directory: $path"
}

require_executable() {
  local path="$1"

  [[ -x "$repo_root/$path" ]] || fail "required file is not executable: $path"
}

validate_json() {
  local path="$1"

  require_file "$path"
  python3 -m json.tool "$repo_root/$path" >/dev/null || fail "invalid JSON: $path"
}

required_dirs=(
  original
  safe
  tests/original
  tests/safe
  scripts
)

required_files=(
  all_cves.json
  dependents.json
  relevant_cves.json
  test-original.sh
  test-safe.sh
)

json_files=(
  all_cves.json
  dependents.json
  relevant_cves.json
)

executable_files=(
  test-original.sh
  test-safe.sh
  scripts/run-tests.sh
  scripts/validate-template.sh
)

for path in "${required_dirs[@]}"; do
  require_dir "$path"
done

for path in "${required_files[@]}"; do
  require_file "$path"
done

for path in "${json_files[@]}"; do
  validate_json "$path"
done

for path in "${executable_files[@]}"; do
  require_executable "$path"
done

printf 'Template validation passed.\n'
