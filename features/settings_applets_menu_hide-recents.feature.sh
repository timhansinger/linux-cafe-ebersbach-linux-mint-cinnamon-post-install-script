FEATURE_ID="settings_applets_menu_hide-recents"
FEATURE_NAME="Applets"
FEATURE_CATEGORY="Settings"
FEATURE_DESC="Menu - Hide Recents"
FEATURE_DEFAULT="true"

run_feature() {
    CONFIG_DIR="${HOME}/.config/cinnamon/spices/menu@cinnamon.org/"
    JSON=$(find "${CONFIG_DIR}" -maxdepth 1 -name "*.json" -type f | head -n1)
    jq '."show-recents".value=false' $JSON | sponge "$JSON"
}
