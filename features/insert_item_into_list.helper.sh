#!/usr/bin/env bash
set -euo pipefail

DCONF_KEY=""
ITEM=""
DRY_RUN=0
SELF_TEST=0
RAW_INPUT=""
HAS_INPUT=0

usage() {
  cat <<'EOF'
Usage:
  insert_item_into_list.helper.sh --key DCONF_KEY --item ITEM [options]

Reads a dconf list (e.g. /org/cinnamon/enabled-extensions), appends ITEM
to the end of the list, but only if it is not already present.

Required:
  --key PATH               dconf key, e.g. /org/cinnamon/enabled-extensions
  --item NAME              Item to append, e.g. DesktopCube@yare

Options:
  --input STRING           Use this list string instead of reading dconf
                           (implies no dconf write; result is printed)
  --self-test              Run built-in test suite and exit
  --dry-run                Show result, do not write dconf
  -h, --help               Show help

Examples:
  ./insert_item_into_list.helper.sh --key /org/cinnamon/enabled-extensions --item DesktopCube@yare
  ./insert_item_into_list.helper.sh --key /org/cinnamon/enabled-extensions --item DesktopCube@yare --dry-run
EOF
}

trim_spaces() {
  local s="$1"
  s="${s#"${s%%[![:space:]]*}"}"
  s="${s%"${s##*[![:space:]]}"}"
  printf '%s' "$s"
}

parse_list_to_entries() {
  local raw="$1"
  local -n entries_ref="$2"

  entries_ref=()

  raw="$(trim_spaces "$raw")"

  if [[ "${raw:0:1}" == '"' ]]; then
    raw="${raw:1}"
  fi
  if [[ "${raw: -1}" == '"' ]]; then
    raw="${raw:0:${#raw}-1}"
  fi

  raw="$(trim_spaces "$raw")"

  # Handle typed-empty forms like: @as []
  if [[ "$raw" == @as* ]]; then
    raw="$(trim_spaces "${raw#@as}")"
  fi

  raw="${raw#[}"
  raw="${raw%]}"

  local IFS=','
  local parts=()
  read -r -a parts <<< "$raw"

  local part
  for part in "${parts[@]}"; do
    part="$(trim_spaces "$part")"
    part="${part#\'}"
    part="${part%\'}"
    if [[ -n "$part" ]]; then
      entries_ref+=("$part")
    fi
  done
}

build_entries_to_list() {
  local -n entries_ref="$1"
  local out=""
  local e
  for e in "${entries_ref[@]}"; do
    if [[ -n "$out" ]]; then
      out+=", "
    fi
    out+="'$e'"
  done
  printf '[%s]' "$out"
}

# Appends item if missing.
# Return codes:
#   0 -> item appended (list changed)
#   2 -> item already present (no change)
insert_item_into_list() {
  local raw_list="$1"
  local item="$2"
  local -n result_ref="$3"

  local -a entries=()
  parse_list_to_entries "$raw_list" entries

  local e
  for e in "${entries[@]}"; do
    if [[ "$e" == "$item" ]]; then
      result_ref="$(build_entries_to_list entries)"
      return 2
    fi
  done

  entries+=("$item")
  result_ref="$(build_entries_to_list entries)"
  return 0
}

assert_eq() {
  local got="$1"
  local want="$2"
  local msg="$3"
  if [[ "$got" != "$want" ]]; then
    echo "FAIL: $msg" >&2
    echo "  wanted: $want" >&2
    echo "  got:    $got" >&2
    return 1
  fi
  return 0
}

run_self_tests() {
  local passed=0
  local failed=0

  run_test() {
    local name="$1"
    shift
    if "$@"; then
      passed=$((passed + 1))
      echo "PASS: $name"
    else
      failed=$((failed + 1))
    fi
  }

  test_append_to_empty_brackets() {
    local out=""
    insert_item_into_list "[]" "DesktopCube@yare" out
    assert_eq "$out" "['DesktopCube@yare']" "append to empty list" || return 1
    return 0
  }

  test_append_to_typed_empty() {
    local out=""
    insert_item_into_list "@as []" "DesktopCube@yare" out
    assert_eq "$out" "['DesktopCube@yare']" "append to typed-empty list" || return 1
    return 0
  }

  test_append_to_existing() {
    local out=""
    insert_item_into_list "['a@x', 'b@x']" "c@x" out
    assert_eq "$out" "['a@x', 'b@x', 'c@x']" "append to non-empty list" || return 1
    return 0
  }

  test_duplicate_noop() {
    local out=""
    local rc
    set +e
    insert_item_into_list "['a@x', 'b@x']" "b@x" out
    rc=$?
    set -e
    assert_eq "$rc" "2" "duplicate returns code 2" || return 1
    assert_eq "$out" "['a@x', 'b@x']" "duplicate keeps list unchanged" || return 1
    return 0
  }

  test_quoted_input() {
    local out=""
    insert_item_into_list "\"['a@x']\"" "b@x" out
    assert_eq "$out" "['a@x', 'b@x']" "handles surrounding quotes" || return 1
    return 0
  }

  run_test "append to empty brackets" test_append_to_empty_brackets
  run_test "append to typed-empty" test_append_to_typed_empty
  run_test "append to existing" test_append_to_existing
  run_test "duplicate no-op" test_duplicate_noop
  run_test "quoted input" test_quoted_input

  echo ""
  echo "Self-test results: $passed passed, $failed failed"

  if (( failed > 0 )); then
    return 1
  fi
  return 0
}

while (($#)); do
  case "$1" in
    --key)
      DCONF_KEY="${2:-}"
      shift 2
      ;;
    --item)
      ITEM="${2:-}"
      shift 2
      ;;
    --input)
      RAW_INPUT="${2:-}"
      HAS_INPUT=1
      shift 2
      ;;
    --self-test)
      SELF_TEST=1
      shift
      ;;
    --dry-run)
      DRY_RUN=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage
      exit 1
      ;;
  esac
done

if (( SELF_TEST == 1 )); then
  run_self_tests
  exit $?
fi

if [[ -z "$ITEM" ]]; then
  echo "Error: --item is required" >&2
  usage
  exit 1
fi

if (( HAS_INPUT == 0 )) && [[ -z "$DCONF_KEY" ]]; then
  echo "Error: --key is required (unless --input is used)" >&2
  usage
  exit 1
fi

RAW_CURRENT=""
if (( HAS_INPUT == 1 )); then
  RAW_CURRENT="$RAW_INPUT"
else
  RAW_CURRENT="$(dconf read "$DCONF_KEY")"
fi

UPDATED=""
if insert_item_into_list "$RAW_CURRENT" "$ITEM" UPDATED; then
  :
else
  rc=$?
  if (( rc == 2 )); then
    echo "Item already exists: $ITEM"
    echo "No changes made."
    exit 0
  fi
  exit "$rc"
fi

if (( HAS_INPUT == 1 )); then
  echo "$UPDATED"
  exit 0
fi

if (( DRY_RUN == 1 )); then
  echo "DRY RUN"
  echo "Current: $RAW_CURRENT"
  echo "Updated: $UPDATED"
  exit 0
fi

dconf write "$DCONF_KEY" "$UPDATED"
echo "Appended $ITEM into $DCONF_KEY"
