FEATURE_ID="settings_applets_menu_set-sidebar-max-width-to-500"
FEATURE_NAME="Applets"
FEATURE_CATEGORY="Settings"
FEATURE_DESC="Menu - Set maximum sidebar width to 500"
FEATURE_DEFAULT="true"

run_feature() {
    CONFIG_DIR="${HOME}/.config/cinnamon/spices/menu@cinnamon.org/"
    JSON=$(find "${CONFIG_DIR}" -maxdepth 1 -name "*.json" -type f | head -n1)
    jq '."sidebar-max-width".value=500' $JSON | sponge "$JSON"
}
