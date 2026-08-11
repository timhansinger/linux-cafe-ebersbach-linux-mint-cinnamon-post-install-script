FEATURE_ID="settings_alttab-switcher_change-style-to-coverflow"
FEATURE_NAME="Alt-Tab switcher"
FEATURE_CATEGORY="Settings"
FEATURE_DESC="Change style to 'coverflow'"
FEATURE_DEFAULT="true"

run_feature() {
    # INFO: The format "'coverflow'" or "'icons'" is important
    dconf write /org/cinnamon/alttab-switcher-style "'coverflow'"
}
