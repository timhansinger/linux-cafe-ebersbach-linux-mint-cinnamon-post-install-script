#!/bin/bash

set -u

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
FEATURE_DIR="$SCRIPT_DIR/features"
MODE="normal"

TITLE="System-Konfiguration"
BACKTITLE="Setup Assistant v1.0"

# Max visible entries in checklist before scrolling.
CHECKLIST_VISIBLE_ROWS=12

FEATURE_FILES=()
FEATURE_IDS=()
FEATURE_NAMES=()
FEATURE_CATEGORIES=()
FEATURE_DESCS=()
FEATURE_DEFAULTS=()
SELECTED_IDS=()
SORTED_CATEGORIES=()

report_errors=()

usage() {
    cat <<'EOF'
Usage: ./run2.sh [--dry-run] [--help]

Modes:
  --dry-run  Print commands only
EOF
}

to_lower() {
    printf '%s' "$1" | tr '[:upper:]' '[:lower:]'
}

normalize_default_state() {
    local value
    value=$(to_lower "${1:-false}")

    case "$value" in
        true|1|on|yes) printf 'on' ;;
        false|0|off|no|"") printf 'off' ;;
        *) printf 'off' ;;
    esac
}

contains_value() {
    local needle="$1"
    shift
    local item
    for item in "$@"; do
        [ "$item" = "$needle" ] && return 0
    done
    return 1
}

remove_value_from_array() {
    local needle="$1"
    shift
    local item
    local new_values=()
    for item in "$@"; do
        if [ "$item" != "$needle" ]; then
            new_values+=("$item")
        fi
    done
    SELECTED_IDS=("${new_values[@]}")
}

get_feature_index_by_id() {
    local id="$1"
    local i
    for ((i = 0; i < ${#FEATURE_IDS[@]}; i++)); do
        if [ "${FEATURE_IDS[$i]}" = "$id" ]; then
            printf '%s' "$i"
            return 0
        fi
    done
    return 1
}

parse_args() {
    while [ "$#" -gt 0 ]; do
        case "$1" in
            --dry-run) MODE="dry-run" ;;
            --help|-h)
                usage
                exit 0
                ;;
            *)
                echo "Unbekanntes Argument: $1"
                usage
                exit 1
                ;;
        esac
        shift
    done
}

load_features() {
    if [ ! -d "$FEATURE_DIR" ]; then
        echo "Fehler: Feature-Verzeichnis fehlt: $FEATURE_DIR"
        exit 1
    fi

    local file
    for file in "$FEATURE_DIR"/*.feature.sh; do
        [ -e "$file" ] || continue
        FEATURE_FILES+=("$file")
    done

    if [ "${#FEATURE_FILES[@]}" -eq 0 ]; then
        echo "Fehler: Keine Feature-Dateien gefunden in $FEATURE_DIR"
        exit 1
    fi

    local FEATURE_ID FEATURE_NAME FEATURE_CATEGORY FEATURE_DESC FEATURE_DEFAULT
    local idx

    for file in "${FEATURE_FILES[@]}"; do
        FEATURE_ID=""
        FEATURE_NAME=""
        FEATURE_CATEGORY=""
        FEATURE_DESC=""
        FEATURE_DEFAULT="false"
        unset -f run_feature

        # shellcheck source=/dev/null
        . "$file"

        if [ -z "${FEATURE_ID:-}" ] || [ -z "${FEATURE_NAME:-}" ] || [ -z "${FEATURE_CATEGORY:-}" ] || [ -z "${FEATURE_DESC:-}" ]; then
            echo "Fehler: Pflichtfelder fehlen in $file"
            echo "Erwartet: FEATURE_ID, FEATURE_NAME, FEATURE_CATEGORY, FEATURE_DESC"
            exit 1
        fi

        if ! declare -F run_feature >/dev/null 2>&1; then
            echo "Fehler: run_feature() fehlt in $file"
            exit 1
        fi

        if ! [[ "$FEATURE_ID" =~ ^[A-Za-z0-9._-]+$ ]]; then
            echo "Fehler: Ungültige FEATURE_ID '$FEATURE_ID' in $file"
            echo "Erlaubt: Buchstaben, Zahlen, Punkt, Unterstrich, Minus"
            exit 1
        fi

        if contains_value "$FEATURE_ID" "${FEATURE_IDS[@]}"; then
            echo "Fehler: Doppelte FEATURE_ID '$FEATURE_ID'"
            exit 1
        fi

        FEATURE_IDS+=("$FEATURE_ID")
        FEATURE_NAMES+=("$FEATURE_NAME")
        FEATURE_CATEGORIES+=("$FEATURE_CATEGORY")
        FEATURE_DESCS+=("$FEATURE_DESC")
        FEATURE_DEFAULTS+=("$(normalize_default_state "${FEATURE_DEFAULT:-false}")")
    done

    for ((idx = 0; idx < ${#FEATURE_IDS[@]}; idx++)); do
        if [ "${FEATURE_DEFAULTS[$idx]}" = "on" ]; then
            SELECTED_IDS+=("${FEATURE_IDS[$idx]}")
        fi
    done
}

build_sorted_categories() {
    local categories=()
    local category

    for category in "${FEATURE_CATEGORIES[@]}"; do
        if ! contains_value "$category" "${categories[@]}"; then
            categories+=("$category")
        fi
    done

    SORTED_CATEGORIES=()
    while IFS= read -r category; do
        [ -n "$category" ] && SORTED_CATEGORIES+=("$category")
    done < <(printf '%s\n' "${categories[@]}" | LC_ALL=C sort)
}

category_totals() {
    local category="$1"
    local total=0
    local selected=0
    local i

    for ((i = 0; i < ${#FEATURE_IDS[@]}; i++)); do
        if [ "${FEATURE_CATEGORIES[$i]}" = "$category" ]; then
            total=$((total + 1))
            if contains_value "${FEATURE_IDS[$i]}" "${SELECTED_IDS[@]}"; then
                selected=$((selected + 1))
            fi
        fi
    done

    printf '%s|%s' "$selected" "$total"
}

edit_category_selection() {
    local category="$1"
    local checklist_args=()
    local current_ids=()
    local i
    local feature_state
    local list_height
    local menu_height
    local selection
    local cleaned
    local selected_in_category=()
    local id
    local item_count

    for ((i = 0; i < ${#FEATURE_IDS[@]}; i++)); do
        if [ "${FEATURE_CATEGORIES[$i]}" = "$category" ]; then
            current_ids+=("${FEATURE_IDS[$i]}")

            feature_state="${FEATURE_DEFAULTS[$i]}"
            if contains_value "${FEATURE_IDS[$i]}" "${SELECTED_IDS[@]}"; then
                feature_state="on"
            fi

            # checklist_args+=("${FEATURE_IDS[$i]}" "${FEATURE_NAMES[$i]} - ${FEATURE_DESCS[$i]}" "$feature_state")
            checklist_args+=("${FEATURE_IDS[$i]}" "${FEATURE_NAMES[$i]} - ${FEATURE_DESCS[$i]}" "$feature_state")
        fi
    done

    item_count=${#current_ids[@]}
    if [ "$item_count" -gt "$CHECKLIST_VISIBLE_ROWS" ]; then
        list_height=$CHECKLIST_VISIBLE_ROWS
    else
        list_height=$item_count
    fi
    [ "$list_height" -lt 6 ] && list_height=6
    menu_height=$((list_height + 9))
    [ "$menu_height" -gt 24 ] && menu_height=24

    selection=$(whiptail --title "$TITLE" --backtitle "$BACKTITLE" \
        --notags --checklist "Kategorie: $category" "$menu_height" 90 "$list_height" \
        "${checklist_args[@]}" \
        3>&1 1>&2 2>&3)

    if [ $? -ne 0 ]; then
        return 1
    fi

    selected_in_category=()
    cleaned=$(printf '%s' "$selection" | tr -d '"')
    if [ -n "$cleaned" ]; then
        for id in $cleaned; do
            selected_in_category+=("$id")
        done
    fi

    for id in "${current_ids[@]}"; do
        if contains_value "$id" "${selected_in_category[@]}"; then
            if ! contains_value "$id" "${SELECTED_IDS[@]}"; then
                SELECTED_IDS+=("$id")
            fi
        else
            remove_value_from_array "$id" "${SELECTED_IDS[@]}"
        fi
    done

    return 0
}

run_selection_hub() {
    if ! command -v whiptail >/dev/null 2>&1; then
        echo "Fehler: whiptail wurde nicht gefunden. Bitte installieren."
        exit 1
    fi

    build_sorted_categories

    local welcome_msg="Kategorie-Menü: Wähle eine Kategorie zum Bearbeiten.\n\nWenn alles passt, wähle CONTINUE."
    if [ "$MODE" = "dry-run" ]; then
        welcome_msg="$welcome_msg\nModus: $MODE"
    fi

    whiptail --title "$TITLE" --backtitle "$BACKTITLE" \
        --msgbox "$welcome_msg" 12 70

    local menu_args=()
    local selection
    local i
    local category
    local stats
    local selected
    local total

    while true; do
        menu_args=()

        for ((i = 0; i < ${#SORTED_CATEGORIES[@]}; i++)); do
            category="${SORTED_CATEGORIES[$i]}"
            stats=$(category_totals "$category")
            selected=${stats%%|*}
            total=${stats##*|}
            menu_args+=("$i" "$category ($selected/$total ausgewählt)")
        done

        menu_args+=("CONTINUE" "Auswahl bestätigen und fortfahren")

        selection=$(whiptail --title "$TITLE" --backtitle "$BACKTITLE" \
            --menu "Kategorien" 20 85 10 \
            "${menu_args[@]}" \
            3>&1 1>&2 2>&3)

        if [ $? -ne 0 ]; then
            echo "Abgebrochen."
            exit 1
        fi

        if [ "$selection" = "CONTINUE" ]; then
            break
        fi

        category="${SORTED_CATEGORIES[$selection]}"
        if ! edit_category_selection "$category"; then
            continue
        fi
    done
}

confirm_selection() {
    local selected_count="${#SELECTED_IDS[@]}"
    local id
    local idx
    local feature_desc
    local feature_name
    local preview_file
    local action

    if [ "$selected_count" -eq 0 ]; then
        whiptail --title "$TITLE" --backtitle "$BACKTITLE" \
            --msgbox "Keine Features ausgewählt. Ende." 8 45
        exit 0
    fi

    preview_file=$(mktemp)
    if [ -z "$preview_file" ] || [ ! -f "$preview_file" ]; then
        echo "Fehler: Konnte temporäre Datei für Vorschau nicht erstellen."
        exit 1
    fi

    {
        for id in "${SELECTED_IDS[@]}"; do
            idx=$(get_feature_index_by_id "$id")
            feature_name="${FEATURE_NAMES[$idx]}"
            feature_desc="${FEATURE_DESCS[$idx]}"
            printf -- '- %s - %s\n' "$feature_name" "$feature_desc"
        done
    } > "$preview_file"

    while true; do
        local menu_prompt="Auswahl bestätigen?\n\nFeatures gesamt: $selected_count"
        if [ "$MODE" = "dry-run" ]; then
            menu_prompt="$menu_prompt\nModus: $MODE"
        fi
        menu_prompt="$menu_prompt\n\nAktion wählen:"

        action=$(whiptail --title "$TITLE" --backtitle "$BACKTITLE" \
            --menu "$menu_prompt" 16 80 2 \
            "CONFIRM" "Auswahl bestätigen und installieren" \
            "DETAILS" "Details anzeigen" \
            3>&1 1>&2 2>&3)

        if [ $? -ne 0 ]; then
            rm -f "$preview_file"
            echo "Abgebrochen."
            exit 1
        fi

        case "$action" in
            CONFIRM)
                break
                ;;
            DETAILS)
                whiptail --title "$TITLE" --backtitle "$BACKTITLE" \
                    --scrolltext --textbox "$preview_file" 24 100
                ;;
        esac
    done

    rm -f "$preview_file"
}

run_selected_features() {
    local selected_count="${#SELECTED_IDS[@]}"
    local feature_success_count=0
    local feature_fail_count=0

    local id idx feature_name feature_file
    local feature_ok
    local output
    local first_line

    echo ""
    echo "=== Update apt ==="
    if [ "$MODE" = "dry-run" ]; then
        echo "[DRY-RUN] would update apt"
    else
        sudo apt-get update -y
    fi

    echo ""
    echo "=== Install prerequisites ==="
    if [ "$MODE" = "dry-run" ]; then
        echo "[DRY-RUN] would install prerequisites"
    else
        sudo apt-get install -y jq moreutils curl unzip
    fi

    echo ""
    if [ "$MODE" = "dry-run" ]; then
        echo "=== Ausführung ($MODE) ==="
    else
        echo "=== Ausführung ==="
    fi

    for id in "${SELECTED_IDS[@]}"; do
        idx=$(get_feature_index_by_id "$id")
        feature_name="${FEATURE_NAMES[$idx]}"
        feature_file="${FEATURE_FILES[$idx]}"

        feature_ok=1
        echo ""
        echo "[$id] $feature_name"

        if [ "$MODE" = "dry-run" ]; then
            echo "[DRY-RUN] would run feature: $id ($feature_name)"
        elif output=$(bash -c ". \"$feature_file\" && run_feature </dev/tty >/dev/tty"); then
        # elif output=$(bash -c ". \"$feature_file\" && run_feature" 2>&1); then
            echo "[OK]"
        else
            echo "[ERR] $output"
            feature_ok=0

            first_line="${output%%$'\n'*}"
            [ -z "$first_line" ] && first_line="Unknown error"
            report_errors+=("$id|run_feature|$first_line")
        fi

        if [ "$feature_ok" -eq 1 ]; then
            feature_success_count=$((feature_success_count + 1))
        else
            feature_fail_count=$((feature_fail_count + 1))
        fi
    done

    echo ""
    echo "=== Restart cinnamon ==="
    if [ "$MODE" = "dry-run" ]; then
        echo "[DRY-RUN] would restart cinnamon"
    else
        cinnamon --replace > /dev/null 2>&1 & disown
    fi

    echo ""
    echo "=== Close nemo ==="
    if [ "$MODE" = "dry-run" ]; then
        echo "[DRY-RUN] would close nemo"
    else
        nemo -q
    fi

    echo ""
    echo "=== Kurzbericht ==="
    if [ "$MODE" = "dry-run" ]; then
        echo "Modus: $MODE"
    fi
    echo "Features ausgewählt: $selected_count"
    if [ "$MODE" = "dry-run" ]; then
        echo "Features ohne Fehler (simuliert): $feature_success_count/$selected_count"
    else
        echo "Features ohne Fehler: $feature_success_count/$selected_count"
        echo "Feature-Fehler: $feature_fail_count"
    fi

    if [ "${#report_errors[@]}" -gt 0 ]; then
        echo ""
        echo "Fehlerdetails:"
        local err
        local err_feature
        local err_cmd
        local err_msg
        for err in "${report_errors[@]}"; do
            err_feature=${err%%|*}
            err=${err#*|}
            err_cmd=${err%%|*}
            err_msg=${err#*|}
            echo "- [$err_feature] $err_cmd"
            echo "  Fehler: $err_msg"
        done
    fi

    whiptail --title "$TITLE" --backtitle "$BACKTITLE" \
        --msgbox "Fertig.\n\nFeatures: $selected_count\nErfolgreich: $feature_success_count\nFehler: $feature_fail_count" 12 50
}

main() {
    parse_args "$@"
    load_features
    run_selection_hub
    confirm_selection
    run_selected_features
}

main "$@"
