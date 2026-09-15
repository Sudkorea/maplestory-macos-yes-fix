#!/bin/bash

TARGET_PLIST="$HOME/Library/Preferences/com.apple.symbolichotkeys.plist"
CACHE_SCRIPT="$HOME/Library/Application Support/MapleStory/.hotkey-cache.sh"
SET_HOTKEYS="/Library/Application Support/Nexon/Maple/MapleStory.app/Contents/SharedSupport/maplestory/bin/set_hotkeys"

pid_field() {
  ps -ww -p "$2" -o "$1" 2>/dev/null
}

find_yes_pids() {
  local rows
  rows=$(ps -axww -o pid=,args=) || return 1
  awk -v target="$TARGET_PLIST" '
    {
      pid = $1
      sub(/^[[:space:]]*[0-9]+[[:space:]]+/, "")
      if ($0 == "YES " target || $0 == "yes " target ||
          $0 == "/usr/bin/YES " target || $0 == "/usr/bin/yes " target)
        print pid
    }
  ' <<< "$rows"
}

loop_chain() {
  local yes_pid="$1" cache_pid wrapper_pid pid owner yes_command
  yes_command=$(pid_field args= "$yes_pid") || return 1
  case "$yes_command" in
    "YES $TARGET_PLIST"|"yes $TARGET_PLIST"|"/usr/bin/YES $TARGET_PLIST"|"/usr/bin/yes $TARGET_PLIST") ;;
    *) return 1 ;;
  esac
  cache_pid=$(pid_field ppid= "$yes_pid") || return 1
  cache_pid=${cache_pid//[[:space:]]/}
  [[ "$cache_pid" =~ ^[0-9]+$ ]] || return 1
  wrapper_pid=$(pid_field ppid= "$cache_pid") || return 1
  wrapper_pid=${wrapper_pid//[[:space:]]/}
  [[ "$wrapper_pid" =~ ^[0-9]+$ ]] || return 1
  [[ "$(pid_field args= "$cache_pid")" == "/bin/bash $CACHE_SCRIPT" ]] || return 1
  [[ "$(pid_field args= "$wrapper_pid")" == "/bin/bash $SET_HOTKEYS" ]] || return 1
  for pid in "$wrapper_pid" "$cache_pid" "$yes_pid"; do
    owner=$(pid_field uid= "$pid") || return 1
    [[ "${owner//[[:space:]]/}" == "$UID" ]] || return 1
  done
  printf '%s %s %s\n' "$wrapper_pid" "$cache_pid" "$yes_pid"
}

stop_loop() {
  local chain="$1" pids snapshots=() current i
  read -r -a pids <<< "$chain"
  for i in 0 1 2; do
    snapshots[$i]=$(pid_field uid=,lstart=,args= "${pids[$i]}") || return 1
    [[ -n "${snapshots[$i]}" ]] || return 1
  done
  [[ "$(loop_chain "${pids[2]}")" == "$chain" ]] || return 1

  # Stop the shells first so ending YES cannot resume the broken restore script.
  for i in 0 1 2; do
    current=$(pid_field uid=,lstart=,args= "${pids[$i]}") || current=""
    [[ -n "$current" ]] || continue
    [[ "$current" == "${snapshots[$i]}" ]] || return 1
    kill -KILL "${pids[$i]}" || return 1
    STOPPED_PIDS="$STOPPED_PIDS ${pids[$i]}"
  done
}

main() {
  local mode="${1:-}" candidates pid chain found=0 failed=0 remaining state
  [[ $# -le 1 && ( -z "$mode" || "$mode" == "--check" ) ]] || {
    echo "Usage: $0 [--check]" >&2
    return 2
  }
  [[ "$(uname -s)" == Darwin && "$EUID" -ne 0 ]] || {
    echo "Run on macOS as your normal user, without sudo." >&2
    return 2
  }
  STOPPED_PIDS=""
  echo "Checking MapleStory hotkey CPU loop..."
  candidates=$(find_yes_pids) || { echo "Could not read processes." >&2; return 1; }
  for pid in $candidates; do
    if ! chain=$(loop_chain "$pid"); then
      echo "Skip PID $pid: MapleStory ownership/parent chain not confirmed." >&2
      failed=1
      continue
    fi
    found=$((found + 1))
    echo "Confirmed MapleStory hotkey loop: PIDs $chain"
    if [[ "$mode" != --check ]] && ! stop_loop "$chain"; then
      echo "Could not finish stopping PID $pid; process state may have changed." >&2
      failed=1
    fi
  done
  if [[ "$mode" == --check ]]; then
    echo "Check only: $found confirmed loop(s). No processes terminated."
    return "$failed"
  fi
  if [[ "$found" -gt 0 ]]; then sleep 1; fi
  for pid in $STOPPED_PIDS; do
    state=$(pid_field stat= "$pid") || state=""
    state=${state//[[:space:]]/}
    if [[ -n "$state" && "$state" != Z* ]]; then
      echo "PID $pid is still present. Check Activity Monitor." >&2
      failed=1
    fi
  done
  remaining=$(find_yes_pids) || { echo "Could not recheck processes." >&2; return 1; }
  if [[ -n "$remaining" ]]; then
    echo "Matching YES process(es) remain. Check Activity Monitor, then rerun." >&2
    failed=1
  fi
  if [[ "$failed" -eq 0 ]]; then
    echo "Done. No matching MapleStory hotkey CPU loop is running."
  fi
  return "$failed"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  set -u
  export PATH=/usr/bin:/bin:/usr/sbin:/sbin
  export LC_ALL=C
  main "$@"
fi
