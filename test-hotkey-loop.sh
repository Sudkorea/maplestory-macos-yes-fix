#!/bin/bash
set -eu
source "$(dirname "$0")/kill-maplestory-hotkey-loop.command"

# Mock ps and kill; this check never signals real processes.
reset_case() {
  MOCK_PRESENT=" 100 101 102 "
  MOCK_CACHE_PARENT=100
  MOCK_OWNER="$UID"
  MOCK_CACHE_COMMAND="/bin/bash $CACHE_SCRIPT"
  MOCK_YES_COMMAND="YES $TARGET_PLIST"
  MOCK_REPLACED=0
  MOCK_FAIL_KILL=0
  MOCK_KILLS=""
  STOPPED_PIDS=""
}

ps() {
  if [[ "$1" == -axww ]]; then
    [[ "$MOCK_PRESENT" != *" 102 "* ]] || printf '  102 %s\n' "$MOCK_YES_COMMAND"
    printf '  999 YES /tmp/unrelated.plist\n'
    return 0
  fi
  local pid="$3" field="$5" command
  [[ "$MOCK_PRESENT" == *" $pid "* ]] || return 1
  case "$pid" in
    100) command="/bin/bash $SET_HOTKEYS" ;;
    101) command="$MOCK_CACHE_COMMAND" ;;
    102) command="$MOCK_YES_COMMAND" ;;
    *) return 1 ;;
  esac
  case "$field" in
    ppid=)
      case "$pid" in
        101) echo "$MOCK_CACHE_PARENT" ;;
        102) echo 101 ;;
        *) echo 1 ;;
      esac ;;
    uid=) echo "$MOCK_OWNER" ;;
    args=) echo "$command" ;;
    stat=) echo S ;;
    uid=,lstart=,args=)
      if [[ "$MOCK_REPLACED" == 1 && "$pid" == 101 && "$MOCK_KILLS" == " 100" ]]; then
        echo "$MOCK_OWNER Wed Sep 16 12:00:00 2026 unrelated-command"
      else
        echo "$MOCK_OWNER Tue Sep 15 12:00:00 2026 $command"
      fi ;;
    *) return 1 ;;
  esac
}

kill() {
  [[ "$1" == -KILL && "$2" =~ ^[0-9]+$ ]] || return 1
  [[ "$MOCK_FAIL_KILL" != "$2" ]] || return 1
  MOCK_KILLS="$MOCK_KILLS $2"
  MOCK_PRESENT=${MOCK_PRESENT/ $2 / }
}

uname() { echo Darwin; }
sleep() { :; }

reset_case
[[ "$(find_yes_pids)" == 102 ]] || exit 1
[[ "$(loop_chain 102)" == '100 101 102' ]] || exit 1
main --check >/dev/null
[[ -z "$MOCK_KILLS" ]] || exit 1
main >/dev/null
[[ "$MOCK_KILLS" == ' 100 101 102' && -z "$(find_yes_pids)" ]] || exit 1
main >/dev/null
[[ "$MOCK_KILLS" == ' 100 101 102' ]] || exit 1

reset_case
MOCK_CACHE_COMMAND="/bin/bash ${CACHE_SCRIPT}.unrelated"
if main >/dev/null 2>&1; then echo 'FAIL: unrelated parent accepted'; exit 1; fi
[[ -z "$MOCK_KILLS" ]] || exit 1

reset_case
MOCK_OWNER=$((UID + 1))
if main >/dev/null 2>&1; then echo 'FAIL: different owner accepted'; exit 1; fi
[[ -z "$MOCK_KILLS" ]] || exit 1

reset_case
MOCK_CACHE_PARENT=1
if main >/dev/null 2>&1; then echo 'FAIL: orphan accepted'; exit 1; fi
[[ -z "$MOCK_KILLS" ]] || exit 1

reset_case
MOCK_YES_COMMAND="YES $TARGET_PLIST.extra"
[[ -z "$(find_yes_pids)" ]] || exit 1

reset_case
MOCK_REPLACED=1
if main >/dev/null 2>&1; then echo 'FAIL: changed identity accepted'; exit 1; fi
[[ "$MOCK_KILLS" == ' 100' ]] || exit 1

reset_case
MOCK_FAIL_KILL=100
if main >/dev/null 2>&1; then echo 'FAIL: signal failure hidden'; exit 1; fi
[[ -z "$MOCK_KILLS" ]] || exit 1

if main --invalid >/dev/null 2>&1; then echo 'FAIL: invalid option accepted'; exit 1; fi
echo 'PASS: exact matching, ancestry, ownership, check-only, stop order, recheck, identity change, signal failure.'
