FEATURE_ID="settings_windows_increase-draggable-border-width"
FEATURE_NAME="Windows"
FEATURE_CATEGORY="Settings"
FEATURE_DESC="Increase draggable border width"
FEATURE_DEFAULT="true"

run_feature() {
    local border_width=24
    dconf write /org/cinnamon/muffin/draggable-border-width $border_width
}
