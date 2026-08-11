FEATURE_ID="settings_update-manager_show-size-column"
FEATURE_NAME="Update Manager"
FEATURE_CATEGORY="Settings"
FEATURE_DESC="Show Size Column"
FEATURE_DEFAULT="true"

run_feature() {
    dconf write /com/linuxmint/updates/show-size-column true
}
