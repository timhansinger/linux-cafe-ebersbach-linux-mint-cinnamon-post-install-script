FEATURE_ID="settings_applets_calendar_use-custom-format"
FEATURE_NAME="Applets"
FEATURE_CATEGORY="Settings"
FEATURE_DESC="Calendar - Use custom format"
FEATURE_DEFAULT="true"

run_feature() {
    CONFIG_DIR="${HOME}/.config/cinnamon/spices/calendar@cinnamon.org/"
    JSON=$(find "${CONFIG_DIR}" -maxdepth 1 -name "*.json" -type f | head -n1)
    jq '."use-custom-format".value=true' $JSON | sponge "$JSON"
}
