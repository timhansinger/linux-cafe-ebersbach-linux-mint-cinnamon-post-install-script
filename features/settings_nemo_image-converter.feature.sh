FEATURE_ID="settings_nemo_image-converter"
FEATURE_NAME="Nemo"
FEATURE_CATEGORY="Settings"
FEATURE_DESC="Install and activate Nemo Image Converter"
FEATURE_DEFAULT="true"

run_feature() {
    sudo apt-get install -y nemo-image-converter

    local actions_dir="$HOME/.local/share/nemo/actions"
    local action_name="convert-image-format@el-amine-404"
    local action_dir="$actions_dir/$action_name"
    local action_zip_url="https://cinnamon-spices.linuxmint.com/files/actions/convert-image-format@el-amine-404.zip"
    local tmp_zip

    if [ -d "$action_dir" ]; then
        echo "[SKIP] Convert Image Format action already installed: $action_dir"
    else
        mkdir -p "$actions_dir"
        tmp_zip=$(mktemp --suffix=".zip")

        wget -O "$tmp_zip" "$action_zip_url"
        unzip "$tmp_zip" -d "$actions_dir"
        rm -f "$tmp_zip"
    fi

    # TODO: Make it better, check if this is included and only remove those
    # dconf dump /org/nemo/plugins/
    # [/]
    # disabled-actions=['convert-image-format@el-amine-404.nemo_action']
    # disabled-extensions=['NemoImageConverter']
    dconf write /org/nemo/plugins/disabled-extensions "@as []"
    dconf write /org/nemo/plugins/disabled-actions "@as []"
}
