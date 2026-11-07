FEATURE_ID="browser_google-chrome"
FEATURE_NAME="Google Chrome"
FEATURE_CATEGORY="Browser"
FEATURE_DESC="Install Google Chrome package via apt"
FEATURE_DEFAULT="false"

run_feature() {
    sudo apt-get install -y google-chrome-stable
}
