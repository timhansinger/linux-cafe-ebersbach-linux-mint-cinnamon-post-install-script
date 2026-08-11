FEATURE_ID="settings_alttab-switcher_show-all-workspaces"
FEATURE_NAME="Alt-Tab switcher"
FEATURE_CATEGORY="Settings"
FEATURE_DESC="Show windows from all workspaces"
FEATURE_DEFAULT="true"

run_feature() {
    dconf write /org/cinnamon/alttab-switcher-show-all-workspaces true
}
