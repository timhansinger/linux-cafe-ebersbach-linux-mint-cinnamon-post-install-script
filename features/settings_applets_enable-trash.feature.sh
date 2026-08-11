FEATURE_ID="settings_applets_enable-trash"
FEATURE_NAME="Applets"
FEATURE_CATEGORY="Settings"
FEATURE_DESC="Enable trash icon"
FEATURE_DEFAULT="true"

run_feature() {
    local applet_name="trash@cinnamon.org"
    local applet_position=1
    local applet_zone=right

    local feature_dir
    local insert_helper
    feature_dir=$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
    insert_helper="$feature_dir/insert_menu_item.helper.sh"
    bash "$insert_helper" --item $applet_name --zone $applet_zone --position $applet_position
}
