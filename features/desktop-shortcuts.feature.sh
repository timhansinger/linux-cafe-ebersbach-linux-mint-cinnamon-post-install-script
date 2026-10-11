FEATURE_ID="desktop-shortcuts"
FEATURE_NAME="Desktop shortcuts"
FEATURE_CATEGORY="Support"
FEATURE_DESC="Create desktop shortcuts"
FEATURE_DEFAULT="true"

run_feature() {
    local feature_dir
    feature_dir=$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
    cp -rf $feature_dir/desktop/* $HOME/Desktop/
}
