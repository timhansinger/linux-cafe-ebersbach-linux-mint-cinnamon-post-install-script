FEATURE_ID="settings_update-manager_do-not-hide-window-after-update"
FEATURE_NAME="Update Manager"
FEATURE_CATEGORY="Settings"
FEATURE_DESC="Do not hide the update manager after applying updates"
FEATURE_DEFAULT="true"

run_feature() {
    dconf write /com/linuxmint/updates/hide-window-after-update false
}
