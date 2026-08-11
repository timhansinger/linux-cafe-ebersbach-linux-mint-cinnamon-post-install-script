FEATURE_ID="settings_update-manager_tracker-security-only"
FEATURE_NAME="Update Manager"
FEATURE_CATEGORY="Settings"
FEATURE_DESC="Only show notifications for security and kernel updates"
FEATURE_DEFAULT="true"

run_feature() {
    dconf write /com/linuxmint/updates/tracker-security-only true
}
