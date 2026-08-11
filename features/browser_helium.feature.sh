FEATURE_ID="browser_helium"
FEATURE_NAME="Helium Browser"
FEATURE_CATEGORY="Browser"
FEATURE_DESC="Install Helium Browser package via apt"
FEATURE_DEFAULT="false"

run_feature() {
    curl -fsSL https://raw.githubusercontent.com/imputnet/helium-linux/main/pubkey.asc | sudo gpg --yes --dearmor -o /usr/share/keyrings/helium.gpg
    echo "deb [signed-by=/usr/share/keyrings/helium.gpg] https://pkg.helium.computer/deb stable main" | sudo tee /etc/apt/sources.list.d/helium.list
    sudo apt-get update && sudo apt-get install -y helium-bin
}
