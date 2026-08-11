FEATURE_ID="software_xnview_mp"
FEATURE_NAME="XnView MP"
FEATURE_CATEGORY="Software"
FEATURE_DESC="Download and install latest stable XnView MP .deb"
FEATURE_DEFAULT="true"

run_feature() {
    local XNVIEW_MP_DEB="XnViewMP-linux-x64.deb"
    wget "https://download.xnview.com/${XNVIEW_MP_DEB}"
    sudo apt-get install -y "./${XNVIEW_MP_DEB}"
    rm -f "${XNVIEW_MP_DEB}"
}
