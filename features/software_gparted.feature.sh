FEATURE_ID="software_gparted"
FEATURE_NAME="GParted"
FEATURE_CATEGORY="Software"
FEATURE_DESC="Install GParted package via apt"
FEATURE_DEFAULT="false"

run_feature() {
    sudo apt-get install -y gparted
}
