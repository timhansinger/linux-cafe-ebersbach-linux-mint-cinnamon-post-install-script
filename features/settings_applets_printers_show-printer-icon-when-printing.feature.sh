FEATURE_ID="settings_applets_printers_show-printer-icon-when-printing"
FEATURE_NAME="Applets"
FEATURE_CATEGORY="Settings"
FEATURE_DESC="Printers - Show printer icon when printing"
FEATURE_DEFAULT="true"

run_feature() {
    CONFIG_DIR="${HOME}/.config/cinnamon/spices/printers@cinnamon.org/"
    JSON=$(find "${CONFIG_DIR}" -maxdepth 1 -name "*.json" -type f | head -n1)
    jq '."show-icon".value="jobs"' $JSON | sponge "$JSON"
}
