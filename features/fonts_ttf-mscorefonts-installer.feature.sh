FEATURE_ID="fonts_ttf-mscorefonts-installer"
FEATURE_NAME="TTF MSCoreFonts Installer"
FEATURE_CATEGORY="Fonts"
FEATURE_DESC="Installer for Microsoft TrueType core fonts via apt"
FEATURE_DEFAULT="true"

run_feature() {
    # sudo apt-get install -y ttf-mscorefonts-installer </dev/tty >/dev/tty

    echo "ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true" | sudo debconf-set-selections
    sudo apt-get install -y ttf-mscorefonts-installer

    # sudo dpkg --configure -a
}
