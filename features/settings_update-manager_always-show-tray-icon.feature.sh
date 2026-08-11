FEATURE_ID="settings_update-manager_always-show-tray-icon"
FEATURE_NAME="Update Manager"
FEATURE_CATEGORY="Settings"
FEATURE_DESC="Always show a tray icon"
FEATURE_DEFAULT="true"

run_feature() {
    dconf write /com/linuxmint/updates/hide-systray false
}
