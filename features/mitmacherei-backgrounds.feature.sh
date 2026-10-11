FEATURE_ID="mitmacherei-backgrounds"
FEATURE_NAME="mitmacherei Backgrounds"
FEATURE_CATEGORY="Wallpaper"
FEATURE_DESC="Install mitmacherei Backgrounds"
FEATURE_DEFAULT="true"

run_feature() {
    local feature_dir
    feature_dir=$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
    sudo cp -rf $feature_dir/mitmacherei-backgrounds/mitmacherei /usr/share/backgrounds/
    sudo cp -f $feature_dir/mitmacherei-backgrounds/mitmacherei.xml /usr/share/cinnamon-background-properties/
}
