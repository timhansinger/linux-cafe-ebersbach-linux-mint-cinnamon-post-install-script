FEATURE_ID="media_ffmpeg"
FEATURE_NAME="FFmpeg"
FEATURE_CATEGORY="Media"
FEATURE_DESC="Install FFmpeg package via apt"
FEATURE_DEFAULT="true"

run_feature() {
    sudo apt-get install -y ffmpeg
}
