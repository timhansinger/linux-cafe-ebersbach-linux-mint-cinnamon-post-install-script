FEATURE_ID="browser_brave"
FEATURE_NAME="Brave Browser"
FEATURE_CATEGORY="Browser"
FEATURE_DESC="Install Brave Browser package via script"
FEATURE_DEFAULT="false"

run_feature() {
    curl -fsS https://dl.brave.com/install.sh | sh
}
