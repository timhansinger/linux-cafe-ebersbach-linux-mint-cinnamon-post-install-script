FEATURE_ID="settings_extensions_desktop-cube"
FEATURE_NAME="Extensions"
FEATURE_CATEGORY="Settings"
FEATURE_DESC="Install Desktop Cube extension (DesktopCube@yare)"
FEATURE_DEFAULT="true"

run_feature() {
    local extensions_dir="$HOME/.local/share/cinnamon/extensions"
    local extension_name="DesktopCube@yare"
    local extension_dir="$extensions_dir/$extension_name"
    local extension_zip_url="https://cinnamon-spices.linuxmint.com/files/extensions/DesktopCube@yare.zip"
    local tmp_zip

    if [ -d "$extension_dir" ]; then
        echo "[SKIP] DesktopCube extension already installed: $extension_dir"
    else
        mkdir -p "$extensions_dir"
        tmp_zip=$(mktemp --suffix=".zip")

        wget -O "$tmp_zip" "$extension_zip_url"
        unzip "$tmp_zip" -d "$extensions_dir"
        rm -f "$tmp_zip"
    fi

    local feature_dir
    local insert_helper
    feature_dir=$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
    insert_helper="$feature_dir/insert_item_into_list.helper.sh"
    bash "$insert_helper" --key /org/cinnamon/enabled-extensions --item "$extension_name"
}
