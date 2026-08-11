FEATURE_ID="media_vlc"
FEATURE_NAME="VLC"
FEATURE_CATEGORY="Media"
FEATURE_DESC="Install VLC package via apt"
FEATURE_DEFAULT="true"

run_feature() {
    sudo apt-get install -y vlc
}
