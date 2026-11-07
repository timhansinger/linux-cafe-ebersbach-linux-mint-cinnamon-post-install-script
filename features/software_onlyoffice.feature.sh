FEATURE_ID="software_onlyoffice"
FEATURE_NAME="OnlyOffice"
FEATURE_CATEGORY="Software"
FEATURE_DESC="Install OnlyOffice package via flatpak"
FEATURE_DEFAULT="false"

run_feature() {
    local remote="flathub"
    local application="org.onlyoffice.desktopeditors"
    sudo flatpak install -y "$remote" "$application"
}
