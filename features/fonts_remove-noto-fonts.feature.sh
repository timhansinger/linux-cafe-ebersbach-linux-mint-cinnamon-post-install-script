FEATURE_ID="fonts_remove-noto-fonts"
FEATURE_NAME="Remove Noto fonts"
FEATURE_CATEGORY="Fonts"
FEATURE_DESC="Removes most Noto fonts via apt purge"
FEATURE_DEFAULT="false"

run_feature() {
    # INFO: we keep fonts-noto-mono since some chromium based browsers depend on it and would be installed then as well
    sudo apt purge -y fonts-noto-core fonts-noto-cjk fonts-noto-color-emoji
    fc-cache -fv
}
