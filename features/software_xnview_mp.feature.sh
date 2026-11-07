FEATURE_ID="software_xnview_mp"
FEATURE_NAME="XnView MP"
FEATURE_CATEGORY="Software"
FEATURE_DESC="Install XnView MP via flatpak"
FEATURE_DEFAULT="true"

run_feature() {
    local remote="flathub"
    local application="com.xnview.XnViewMP"
    sudo flatpak install -y "$remote" "$application"
}
