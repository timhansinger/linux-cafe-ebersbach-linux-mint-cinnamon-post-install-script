FEATURE_ID="browser_google-chrome"
FEATURE_NAME="Google Chrome"
FEATURE_CATEGORY="Browser"
FEATURE_DESC="Download and install latest stable Chrome .deb"
FEATURE_DEFAULT="false"

run_feature() {
    local CHROME_DEB="google-chrome-stable_current_amd64.deb"
    wget "https://dl.google.com/linux/direct/${CHROME_DEB}"
    sudo apt-get install -y "./${CHROME_DEB}"
    rm -f "${CHROME_DEB}"
}
