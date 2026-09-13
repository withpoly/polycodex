#!/usr/bin/env bash

set -u

json_escape() {
  local value=$1
  value=${value//\\/\\\\}
  value=${value//\"/\\\"}
  value=${value//$'\b'/\\b}
  value=${value//$'\f'/\\f}
  value=${value//$'\n'/\\n}
  value=${value//$'\r'/\\r}
  value=${value//$'\t'/\\t}
  printf '%s' "$value"
}

emit_output() {
  local context=$1
  local message=$2
  printf '{"systemMessage":"%s","hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"%s"}}\n' \
    "$(json_escape "$message")" \
    "$(json_escape "$context")"
}

# Codex sends hook metadata on stdin. This hook does not need any of it.
cat >/dev/null

if ! command -v poly >/dev/null 2>&1; then
  context='<poly-status>
Poly memory context could not be loaded for this session because the Poly CLI is not installed. Do not assume that the user has no Poly memories. Install the CLI from the Downloads menu in the Poly desktop app, then start a new Codex task to load the context.
</poly-status>'
  emit_output "$context" 'Poly · memory unavailable — install the Poly CLI, then start a new task'
  printf '%s\n' 'Poly: the Poly CLI is not installed. Install it from Poly → Downloads.' >&2
  exit 0
fi

summary=$(NO_COLOR=1 poly memory summary 2>&1)
status=$?
if [ "$status" -ne 0 ]; then
  context='<poly-status>
Poly memory context could not be loaded for this session. Do not assume that the user has no Poly memories. The Poly desktop app must be running and signed in. Start Poly, then start a new Codex task to load the context.

CLI response:
'"$summary"'
</poly-status>'
  emit_output "$context" 'Poly · memory unavailable — start Poly, then start a new task'
  printf 'Poly: memory context could not be loaded: %s\n' "$summary" >&2
  exit 0
fi

context='<poly-memory-context>
The following context was recalled from Poly, the user’s persistent second brain, at the start of this session. Use it as background about the user and their recent work. User-authored profile details and current corrections are authoritative; AI-generated profile details and memory notes can be fallible. Preserve dates when applying this context, and follow Poly links or search Poly when the source material is needed.

'"$summary"'
</poly-memory-context>'
emit_output "$context" 'Poly · memory context loaded'
