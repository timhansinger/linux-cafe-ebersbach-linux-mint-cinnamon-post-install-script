FEATURE_ID="settings_software-manager_allow-unverified-flatpaks"
FEATURE_NAME="Software Manager"
FEATURE_CATEGORY="Settings"
FEATURE_DESC="Show unverified Flatpaks (not recommended)"
FEATURE_DEFAULT="false"

run_feature() {
    dconf write /com/linuxmint/install/allow-unverified-flatpaks true
}
