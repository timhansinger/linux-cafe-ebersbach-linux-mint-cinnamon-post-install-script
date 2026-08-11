FEATURE_ID="settings_nemo_hide-mounted-drives-on-desktop"
FEATURE_NAME="Nemo"
FEATURE_CATEGORY="Settings"
FEATURE_DESC="Hide mounted drives on desktop"
FEATURE_DEFAULT="true"

run_feature() {
    dconf write /org/nemo/desktop/volumes-visible false
}
