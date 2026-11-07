FEATURE_ID="software_xnview_mp"
FEATURE_NAME="XnView MP"
FEATURE_CATEGORY="Software"
FEATURE_DESC="Install XnView MP via flatpak"
FEATURE_DEFAULT="true"

run_feature() {
    flatpak install -y flathub com.xnview.XnViewMP
}
