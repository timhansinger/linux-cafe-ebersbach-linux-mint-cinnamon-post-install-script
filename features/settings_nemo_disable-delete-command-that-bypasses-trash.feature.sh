FEATURE_ID="settings_nemo_disable-delete-command-that-bypasses-trash"
FEATURE_NAME="Nemo"
FEATURE_CATEGORY="Settings"
FEATURE_DESC="Disable a Delete command that bypasses Trash"
FEATURE_DEFAULT="true"

run_feature() {
    dconf write /org/nemo/preferences/enable-delete false
}
