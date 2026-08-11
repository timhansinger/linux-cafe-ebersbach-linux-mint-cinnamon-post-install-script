FEATURE_ID="settings_nemo_show-new-folder-icon-in-toolbar"
FEATURE_NAME="Nemo"
FEATURE_CATEGORY="Settings"
FEATURE_DESC="Show New Folder icon in Toolbar"
FEATURE_DEFAULT="true"

run_feature() {
    dconf write /org/nemo/preferences/show-new-folder-icon-toolbar true
}
