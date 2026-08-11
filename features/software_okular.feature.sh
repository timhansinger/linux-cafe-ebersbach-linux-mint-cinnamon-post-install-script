FEATURE_ID="software_okular"
FEATURE_NAME="Okular"
FEATURE_CATEGORY="Software"
FEATURE_DESC="Install Okular package via apt"
FEATURE_DEFAULT="true"

run_feature() {
    sudo apt-get install -y okular
}
