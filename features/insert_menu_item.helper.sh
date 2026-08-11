#!/usr/bin/env bash
set -euo pipefail

DCONF_KEY="/org/cinnamon/enabled-applets"
PANEL="panel1"
ZONE="right"
POSITION="-1"
ITEM=""
DRY_RUN=0
SAMPLE=0
SELF_TEST=0
RAW_INPUT=""

SAMPLE_DATA="['panel1:left:0:menu@cinnamon.org:0', 'panel1:left:1:separator@cinnamon.org:1', 'panel1:left:2:grouped-window-list@cinnamon.org:2', 'panel1:right:1:systray@cinnamon.org:3', 'panel1:right:2:xapp-status@cinnamon.org:4', 'panel1:right:3:notifications@cinnamon.org:5', 'panel1:right:4:printers@cinnamon.org:6', 'panel1:right:5:removable-drives@cinnamon.org:7', 'panel1:right:6:keyboard@cinnamon.org:8', 'panel1:right:7:favorites@cinnamon.org:9', 'panel1:right:8:network@cinnamon.org:10', 'panel1:right:9:sound@cinnamon.org:11', 'panel1:right:10:power@cinnamon.org:12', 'panel1:right:11:calendar@cinnamon.org:13', 'panel1:right:12:cornerbar@cinnamon.org:14', 'panel1:right:0:trash@cinnamon.org:15']"

usage() {
  cat <<'EOF'
Usage:
  insert_menu_item.sh --item ITEM_NAME [options]

Required:
  --item NAME              Applet name, e.g. mytrash@cinnamon.org

Options:
  --panel NAME             Panel id (default: panel1)
  --zone NAME              left|center|right (default: right)
  --position N             Absolute (>=0) or relative (<0), default: -1
                           -1 means "last entry"
  --key PATH               dconf key (default: /org/cinnamon/enabled-applets)
  --input STRING           Use this list string instead of dconf read
  --sample                 Use built-in sample data (implies --dry-run)
  --self-test              Run built-in test suite and exit
  --dry-run                Show result, do not write dconf
  -h, --help               Show help

Examples:
  ./insert_menu_item.sh --item mytrash@cinnamon.org --zone right --position 0 --dry-run --sample
  ./insert_menu_item.sh --item mytrash@cinnamon.org --zone right --position -1
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

  if [[ "${raw:0:1}" == '"' ]]; then
    raw="${raw:1}"
  fi
  if [[ "${raw: -1}" == '"' ]]; then
    raw="${raw:0:${#raw}-1}"
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

insert_menu_item() {
  local raw_list="$1"
  local panel="$2"
  local zone="$3"
  local pos_spec="$4"
  local item_name="$5"
  local -n result_ref="$6"

  local -a entries=()
  parse_list_to_entries "$raw_list" entries

  local max_nr=-1
  local existing=0

  local -a group_indices=()
  local -a group_positions=()

  local i
  for i in "${!entries[@]}"; do
    local e="${entries[$i]}"
    local e_panel e_zone e_pos e_name e_nr
    IFS=':' read -r e_panel e_zone e_pos e_name e_nr <<< "$e"

    if [[ -z "${e_panel:-}" || -z "${e_zone:-}" || -z "${e_pos:-}" || -z "${e_name:-}" || -z "${e_nr:-}" ]]; then
      echo "Error: invalid entry format: $e" >&2
      return 1
    fi

    if [[ "$e_name" == "$item_name" ]]; then
      existing=1
    fi

    if [[ "$e_nr" =~ ^[0-9]+$ ]] && (( e_nr > max_nr )); then
      max_nr=$e_nr
    fi

    if [[ "$e_panel" == "$panel" && "$e_zone" == "$zone" ]]; then
      if ! [[ "$e_pos" =~ ^-?[0-9]+$ ]]; then
        echo "Error: invalid position in entry: $e" >&2
        return 1
      fi
      group_indices+=("$i")
      group_positions+=("$e_pos")
    fi
  done

  if (( existing == 1 )); then
    result_ref="$(build_entries_to_list entries)"
    return 2
  fi

  if ! [[ "$pos_spec" =~ ^-?[0-9]+$ ]]; then
    echo "Error: --position must be an integer" >&2
    return 1
  fi

  local -a sorted_pairs=()
  if ((${#group_indices[@]} > 0)); then
    local lines=""
    local k
    for k in "${!group_indices[@]}"; do
      lines+="${group_positions[$k]}:${group_indices[$k]}"$'\n'
    done
    mapfile -t sorted_pairs < <(printf '%s' "$lines" | sort -t: -k1,1n)
  fi

  local n="${#sorted_pairs[@]}"
  local insert_pos

  if (( pos_spec >= 0 )); then
    insert_pos="$pos_spec"
    if (( insert_pos > n )); then
      insert_pos="$n"
    fi
  else
    insert_pos=$(( n + pos_spec + 1 ))
    if (( insert_pos < 0 )); then
      insert_pos=0
    fi
    if (( insert_pos > n )); then
      insert_pos="$n"
    fi
  fi

  local idx
  local k
  for ((k=insert_pos; k<n; k++)); do
    idx="${sorted_pairs[$k]#*:}"

    local e="${entries[$idx]}"
    local e_panel e_zone e_pos e_name e_nr
    IFS=':' read -r e_panel e_zone e_pos e_name e_nr <<< "$e"

    entries[$idx]="$e_panel:$e_zone:$((e_pos + 1)):$e_name:$e_nr"
  done

  local new_nr=$((max_nr + 1))
  local new_entry="$panel:$zone:$insert_pos:$item_name:$new_nr"
  entries+=("$new_entry")

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

list_has_entry() {
  local raw_list="$1"
  local needle="$2"
  local -a entries=()
  parse_list_to_entries "$raw_list" entries

  local e
  for e in "${entries[@]}"; do
    if [[ "$e" == "$needle" ]]; then
      return 0
    fi
  done
  return 1
}

assert_has_entry() {
  local raw_list="$1"
  local needle="$2"
  local msg="$3"
  if ! list_has_entry "$raw_list" "$needle"; then
    echo "FAIL: $msg" >&2
    echo "  missing entry: $needle" >&2
    return 1
  fi
  return 0
}

assert_zone_consecutive() {
  local raw_list="$1"
  local panel="$2"
  local zone="$3"
  local expected_count="$4"
  local msg="$5"

  local -a entries=()
  parse_list_to_entries "$raw_list" entries

  local -a positions=()
  local e
  for e in "${entries[@]}"; do
    local e_panel e_zone e_pos e_name e_nr
    IFS=':' read -r e_panel e_zone e_pos e_name e_nr <<< "$e"
    if [[ "$e_panel" == "$panel" && "$e_zone" == "$zone" ]]; then
      positions+=("$e_pos")
    fi
  done

  if (( ${#positions[@]} != expected_count )); then
    echo "FAIL: $msg" >&2
    echo "  expected count: $expected_count" >&2
    echo "  got count:      ${#positions[@]}" >&2
    return 1
  fi

  local -a sorted=()
  if (( ${#positions[@]} > 0 )); then
    mapfile -t sorted < <(printf '%s\n' "${positions[@]}" | sort -n)
  fi

  local i
  for i in "${!sorted[@]}"; do
    if [[ "${sorted[$i]}" != "$i" ]]; then
      echo "FAIL: $msg" >&2
      echo "  expected consecutive position: $i" >&2
      echo "  got position:                 ${sorted[$i]}" >&2
      return 1
    fi
  done

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

  test_duplicate_noop() {
    local out=""
    local rc
    set +e
    insert_menu_item "$SAMPLE_DATA" "panel1" "right" "0" "trash@cinnamon.org" out
    rc=$?
    set -e

    assert_eq "$rc" "2" "duplicate returns code 2" || return 1
    assert_eq "$out" "$SAMPLE_DATA" "duplicate keeps list unchanged" || return 1
    return 0
  }

  test_absolute_zero_insert() {
    local out=""
    insert_menu_item "$SAMPLE_DATA" "panel1" "right" "0" "mytrash@cinnamon.org" out

    assert_has_entry "$out" "panel1:right:0:mytrash@cinnamon.org:16" "insert at absolute position 0" || return 1
    assert_zone_consecutive "$out" "panel1" "right" "14" "right zone remains consecutive after insert" || return 1
    assert_has_entry "$out" "panel1:left:0:menu@cinnamon.org:0" "left zone unchanged entry 0" || return 1
    assert_has_entry "$out" "panel1:left:1:separator@cinnamon.org:1" "left zone unchanged entry 1" || return 1
    assert_has_entry "$out" "panel1:left:2:grouped-window-list@cinnamon.org:2" "left zone unchanged entry 2" || return 1
    return 0
  }

  test_absolute_too_high_clamped() {
    local out=""
    insert_menu_item "$SAMPLE_DATA" "panel1" "right" "999" "mytrash@cinnamon.org" out

    assert_has_entry "$out" "panel1:right:13:mytrash@cinnamon.org:16" "absolute overflow clamps to zone max" || return 1
    assert_zone_consecutive "$out" "panel1" "right" "14" "right zone consecutive when clamped" || return 1
    return 0
  }

  test_relative_last_minus_one() {
    local out=""
    insert_menu_item "$SAMPLE_DATA" "panel1" "right" "-1" "mytrash@cinnamon.org" out

    assert_has_entry "$out" "panel1:right:13:mytrash@cinnamon.org:16" "-1 inserts as last entry" || return 1
    assert_zone_consecutive "$out" "panel1" "right" "14" "right zone consecutive for -1" || return 1
    return 0
  }

  test_relative_too_negative_clamps_zero() {
    local out=""
    insert_menu_item "$SAMPLE_DATA" "panel1" "right" "-999" "mytrash@cinnamon.org" out

    assert_has_entry "$out" "panel1:right:0:mytrash@cinnamon.org:16" "negative overflow clamps to 0" || return 1
    assert_zone_consecutive "$out" "panel1" "right" "14" "right zone consecutive after negative clamp" || return 1
    return 0
  }

  test_item_nr_uses_global_max() {
    local custom="['panel1:left:0:a@x:7', 'panel1:right:0:b@x:42']"
    local out=""
    insert_menu_item "$custom" "panel1" "left" "1" "new@x" out

    assert_has_entry "$out" "panel1:left:1:new@x:43" "item number is global max plus one" || return 1
    return 0
  }

  test_empty_zone_insert() {
    local custom="['panel1:left:0:a@x:0']"
    local out=""
    insert_menu_item "$custom" "panel1" "center" "999" "new@x" out

    assert_has_entry "$out" "panel1:center:0:new@x:1" "empty zone absolute clamp inserts at 0" || return 1
    assert_zone_consecutive "$out" "panel1" "center" "1" "center zone consecutive with one item" || return 1
    return 0
  }

  test_invalid_position_errors() {
    local out=""
    local rc
    set +e
    insert_menu_item "$SAMPLE_DATA" "panel1" "right" "abc" "mytrash@cinnamon.org" out
    rc=$?
    set -e

    assert_eq "$rc" "1" "invalid position returns error" || return 1
    return 0
  }

  run_test "duplicate no-op" test_duplicate_noop
  run_test "absolute position 0" test_absolute_zero_insert
  run_test "absolute high clamped" test_absolute_too_high_clamped
  run_test "relative -1 is last" test_relative_last_minus_one
  run_test "relative clamp to zero" test_relative_too_negative_clamps_zero
  run_test "global max item number" test_item_nr_uses_global_max
  run_test "empty zone insert" test_empty_zone_insert
  run_test "invalid position errors" test_invalid_position_errors

  echo ""
  echo "Self-test results: $passed passed, $failed failed"

  if (( failed > 0 )); then
    return 1
  fi
  return 0
}

while (($#)); do
  case "$1" in
    --item)
      ITEM="${2:-}"
      shift 2
      ;;
    --panel)
      PANEL="${2:-}"
      shift 2
      ;;
    --zone)
      ZONE="${2:-}"
      shift 2
      ;;
    --position)
      POSITION="${2:-}"
      shift 2
      ;;
    --key)
      DCONF_KEY="${2:-}"
      shift 2
      ;;
    --input)
      RAW_INPUT="${2:-}"
      shift 2
      ;;
    --sample)
      SAMPLE=1
      shift
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

if [[ "$ZONE" != "left" && "$ZONE" != "center" && "$ZONE" != "right" ]]; then
  echo "Error: --zone must be one of left|center|right" >&2
  exit 1
fi

if (( SAMPLE == 1 )); then
  DRY_RUN=1
fi

RAW_CURRENT=""
if [[ -n "$RAW_INPUT" ]]; then
  RAW_CURRENT="$RAW_INPUT"
elif (( SAMPLE == 1 )); then
  RAW_CURRENT="$SAMPLE_DATA"
else
  RAW_CURRENT="$(dconf read "$DCONF_KEY")"
fi

UPDATED=""
if insert_menu_item "$RAW_CURRENT" "$PANEL" "$ZONE" "$POSITION" "$ITEM" UPDATED; then
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

if (( DRY_RUN == 1 )); then
  echo "DRY RUN"
  echo "Current: $RAW_CURRENT"
  echo "Updated: $UPDATED"
  exit 0
fi

dconf write "$DCONF_KEY" "$UPDATED"
echo "Inserted $ITEM into $PANEL/$ZONE at position $POSITION"
