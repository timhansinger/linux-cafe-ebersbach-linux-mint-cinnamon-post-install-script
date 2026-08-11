FEATURE_ID="settings_applets_temperature"
FEATURE_NAME="Applets"
FEATURE_CATEGORY="Settings"
FEATURE_DESC="Install Temperature applet (temperature@fevimu)"
FEATURE_DEFAULT="true"

run_feature() {
    local applets_dir="$HOME/.local/share/cinnamon/applets"
    local applet_name="temperature@fevimu"
    local applet_dir="$applets_dir/$applet_name"
    local applet_zip_url="https://cinnamon-spices.linuxmint.com/files/applets/temperature@fevimu.zip"
    local tmp_zip

    if [ -d "$applet_dir" ]; then
        echo "[SKIP] Temperature applet already installed: $applet_dir"
    else
        mkdir -p "$applets_dir"
        tmp_zip=$(mktemp --suffix=".zip")

        wget -O "$tmp_zip" "$applet_zip_url"
        unzip "$tmp_zip" -d "$applets_dir"
        rm -f "$tmp_zip"
    fi

    local applet_position=1
    local applet_zone=right

    local feature_dir
    local insert_helper
    feature_dir=$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
    insert_helper="$feature_dir/insert_menu_item.helper.sh"
    bash "$insert_helper" --item $applet_name --zone $applet_zone --position $applet_position
}
