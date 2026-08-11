FEATURE_ID="mint-backgrounds"
FEATURE_NAME="Mint Backgrounds"
FEATURE_CATEGORY="Wallpaper"
FEATURE_DESC="Install Mint Backgrounds via apt"
FEATURE_DEFAULT="true"

run_feature() {
    sudo apt-get install -y mint-backgrounds-*
}
