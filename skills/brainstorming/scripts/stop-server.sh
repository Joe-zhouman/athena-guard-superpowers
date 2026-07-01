#!/usr/bin/env bash
# Stop the brainstorm server and clean up
# Usage: stop-server.sh <session_dir>
#
# Kills the server process. Only deletes session directory if it's
# under /tmp (ephemeral). Persistent directories (.superpowers/) are
# kept so mockups can be reviewed later.

set -uo pipefail

SESSION_DIR="${1:-}"

if [[ -z "${SESSION_DIR}" ]]; then
  echo '{"error": "Usage: stop-server.sh <session_dir>"}'
  exit 1
fi

STATE_DIR="${SESSION_DIR}/state"
PID_FILE="${STATE_DIR}/server.pid"

# Verify the PID file actually belongs to this server before signaling it.
# A predictable temp brainstorm-* path lets a local attacker plant a PID
# file pointing at any process; refusing to signal non-node PIDs stops
# that escalation. Returns 0 if PID looks like ours, 1 otherwise.
#
# ps portability: GNU/procps and BSD/macOS support `ps -o comm= -p <pid>`.
# MSYS/Git Bash does NOT (its ps rejects -o) — there we fall back to
# `ps -l -p <pid>` and match the COMMAND column. Without this fallback,
# pid_is_ours always returns false on Git Bash and stop never cleans up.
pid_is_ours() {
  local p="$1"
  # Must be a positive integer
  [[ "$p" =~ ^[0-9]+$ ]] || return 1
  # Must be running
  kill -0 "$p" 2> /dev/null || return 1
  # Process name must be node (the brainstorm server is node server.cjs)
  local comm line
  comm=$(ps -o comm= -p "$p" 2> /dev/null | tr -d ' ' || true)
  if [[ -z "$comm" ]]; then
    # ps -o unsupported (MSYS/Git Bash). Parse `ps -l`'s COMMAND column instead.
    # Typical MSYS row:  PID PPID PGID WINPID TTY UID STIME COMMAND
    line=$(ps -l -p "$p" 2>/dev/null | awk 'NR==2 {print $NF}')
    comm=$(basename "$line" 2>/dev/null | tr -d ' ')
  fi
  [[ "$comm" == "node" || "$comm" == "node.exe" ]] || return 1
  return 0
}

if [[ -f "$PID_FILE" ]]; then
  pid=$(cat "$PID_FILE" 2> /dev/null || echo "")

  if pid_is_ours "$pid"; then
    # Try to stop gracefully, fallback to force if still alive
    kill "$pid" 2> /dev/null || true

    # Wait for graceful shutdown (up to ~2s)
    for i in {1..20}; do
      if ! kill -0 "$pid" 2> /dev/null; then
        break
      fi
      sleep 0.1
    done

    # If still running, escalate to SIGKILL
    if kill -0 "$pid" 2> /dev/null; then
      kill -9 "$pid" 2> /dev/null || true

      # Give SIGKILL a moment to take effect
      sleep 0.1
    fi

    if kill -0 "$pid" 2> /dev/null; then
      echo '{"status": "failed", "error": "process still running"}'
      exit 1
    fi
  else
    # PID file exists but doesn't point at our node server. Don't signal
    # anything — that's the H2 attack. Leave the file alone and report.
    echo '{"status": "skipped", "error": "PID file does not point at a node server; refusing to signal"}'
    exit 1
  fi

  rm -f "$PID_FILE" "${STATE_DIR}/server.log"

  # Only delete ephemeral temp directories. Two-stage guard against the
  # H1 symlink-escape attack (where an attacker plants
  # /tmp/x/state/escape -> /home/user and `rm -rf /tmp/x` follows it
  # into the victim's home):
  #
  #   1. Resolve SESSION_DIR with realpath -m. If SESSION_DIR itself is a
  #      symlink, the resolved path will not start with the temp base and
  #      the outer guard refuses.
  #   2. Scan the SESSION_DIR tree for ANY symlink (find -type l). If one
  #      exists, refuse — `rm -rf` would follow it during recursion. The
  #      brainstorm session dir is written entirely by start-server.sh
  #      (logs + pid only), so a legitimate tree has zero symlinks; any
  #      symlink present is suspicious by definition.
  #
  # Temp base mirrors start-server.sh: TMPDIR (POSIX) > TEMP/TMP
  # (Windows/Git Bash, where MSYS maps to /c/Users/.../Temp) > /tmp.
  # This must accept BOTH /tmp/* (Linux/macOS) and the MSYS temp path
  # (Git Bash on Windows) — otherwise Windows sessions never get cleaned.
  TMP_BASE="${TMPDIR:-${TEMP:-${TMP:-/tmp}}}"
  resolved=""
  if command -v realpath >/dev/null 2>&1; then
    resolved=$(realpath -m "$SESSION_DIR" 2> /dev/null || echo "")
    tmp_resolved=$(realpath -m "$TMP_BASE" 2> /dev/null || echo "$TMP_BASE")
  else
    # realpath unavailable (rare on modern systems): fall back to literal compare.
    resolved="$SESSION_DIR"
    tmp_resolved="$TMP_BASE"
  fi
  # Accept if resolved is under the temp base. Compare both the literal
  # prefix and the realpath prefix so a SESSION_DIR given as /tmp/... works
  # even when TMP_BASE resolves elsewhere, and vice-versa.
  under_temp="false"
  if [[ -n "$resolved" ]]; then
    if [[ "$resolved" == "$tmp_resolved"/* ]]; then under_temp="true"; fi
    if [[ "$resolved" == /tmp/* ]]; then under_temp="true"; fi
    # Git Bash: MSYS temp is typically /c/Users/<u>/AppData/Local/Temp or /tmp (aliased).
    if [[ "$resolved" == */Local/Temp/* || "$resolved" == */AppData/Local/Temp/* ]]; then under_temp="true"; fi
  fi
  if [[ "$under_temp" != "true" ]]; then
    echo '{"status": "stopped", "cleanup": "skipped (not under OS temp after realpath)"}'
    exit 0
  fi
  # /tmp prefix confirmed. Refuse if any symlink lurks inside.
  symlinks=$(find "$resolved" -type l 2>/dev/null || true)
  if [[ -n "$symlinks" ]]; then
    echo '{"status": "stopped", "cleanup": "skipped (symlink inside session dir — possible escape attempt)"}'
    echo "  symlinks found:" >&2
    echo "$symlinks" >&2
    exit 0
  fi
  rm -rf "$resolved"

  echo '{"status": "stopped"}'
else
  echo '{"status": "not_running"}'
fi
