FEATURE_ID="settings_applets_menu_hide-favorites"
FEATURE_NAME="Applets"
FEATURE_CATEGORY="Settings"
FEATURE_DESC="Menu - Hide Favorites"
FEATURE_DEFAULT="true"

run_feature() {
    CONFIG_DIR="${HOME}/.config/cinnamon/spices/menu@cinnamon.org/"
    JSON=$(find "${CONFIG_DIR}" -maxdepth 1 -name "*.json" -type f | head -n1)
    jq '."show-favorites".value=false' $JSON | sponge "$JSON"
}
