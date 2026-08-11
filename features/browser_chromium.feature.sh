FEATURE_ID="browser_chromium"
FEATURE_NAME="Chromium"
FEATURE_CATEGORY="Browser"
FEATURE_DESC="Install Chromium package via apt"
FEATURE_DEFAULT="false"

run_feature() {
    sudo apt-get install -y chromium
}
