#!/usr/bin/env bash

set -eu

plugin_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
test_root=$(mktemp -d)
trap 'rm -rf "$test_root"' EXIT

assert_contains() {
  case $1 in
    *"$2"*) ;;
    *)
      printf 'expected output to contain: %s\nactual output: %s\n' "$2" "$1" >&2
      exit 1
      ;;
  esac
}

mkdir -p "$test_root/bin"
cat >"$test_root/bin/poly" <<'EOF'
#!/usr/bin/env bash
printf '%s\n' 'Memory context' '  User profile: Ada "Lovelace"' 'Recent memories: ship C:\poly'
EOF
chmod +x "$test_root/bin/poly"

output=$(printf '{}\n' | PATH="$test_root/bin:/usr/bin:/bin" bash "$plugin_root/hooks/session-start.sh" 2>"$test_root/stderr")
assert_contains "$output" '"systemMessage":"Poly · memory context loaded"'
assert_contains "$output" '"hookEventName":"SessionStart"'
assert_contains "$output" '<poly-memory-context>\n'
assert_contains "$output" 'User profile: Ada \"Lovelace\"'
assert_contains "$output" 'ship C:\\poly'
assert_contains "$output" '</poly-memory-context>'
test ! -s "$test_root/stderr"

cat >"$test_root/bin/poly" <<'EOF'
#!/usr/bin/env bash
printf '%s\n' 'error: the Poly app is not running' >&2
exit 69
EOF
chmod +x "$test_root/bin/poly"

output=$(printf '{}\n' | PATH="$test_root/bin:/usr/bin:/bin" bash "$plugin_root/hooks/session-start.sh" 2>"$test_root/stderr")
assert_contains "$output" '"systemMessage":"Poly · memory unavailable — start Poly, then start a new task"'
assert_contains "$output" '<poly-status>\n'
assert_contains "$output" 'Do not assume that the user has no Poly memories.'
assert_contains "$output" 'error: the Poly app is not running'
assert_contains "$(cat "$test_root/stderr")" 'Poly: memory context could not be loaded'

rm "$test_root/bin/poly"
output=$(printf '{}\n' | PATH="$test_root/bin:/usr/bin:/bin" bash "$plugin_root/hooks/session-start.sh" 2>"$test_root/stderr")
assert_contains "$output" '"systemMessage":"Poly · memory unavailable — install the Poly CLI, then start a new task"'
assert_contains "$output" 'Poly CLI is not installed'
assert_contains "$(cat "$test_root/stderr")" 'Poly: the Poly CLI is not installed'

printf '%s\n' 'Codex session-start hook tests passed'
