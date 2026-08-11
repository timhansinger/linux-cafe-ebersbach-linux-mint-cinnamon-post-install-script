FEATURE_ID="settings_applets_menu_disable-symbolic-category-icons"
FEATURE_NAME="Applets"
FEATURE_CATEGORY="Settings"
FEATURE_DESC="Menu - Disable symbolic icons for categories"
FEATURE_DEFAULT="false"

run_feature() {
    CONFIG_DIR="${HOME}/.config/cinnamon/spices/menu@cinnamon.org/"
    JSON=$(find "${CONFIG_DIR}" -maxdepth 1 -name "*.json" -type f | head -n1)
    jq '."symbolic-category-icons".value=false' $JSON | sponge "$JSON"
}
