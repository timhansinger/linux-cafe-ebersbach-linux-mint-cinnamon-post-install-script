FEATURE_ID="settings_alttab-switcher_show-current-monitor"
FEATURE_NAME="Alt-Tab switcher"
FEATURE_CATEGORY="Settings"
FEATURE_DESC="Show windows from current monitor"
FEATURE_DEFAULT="true"

run_feature() {
    dconf write /org/cinnamon/alttab-switcher-show-current-monitor true
}
