FEATURE_ID="printer_hplip"
FEATURE_NAME="HP Linux Printing and Imaging System (HPLIP)"
FEATURE_CATEGORY="Printer"
FEATURE_DESC="Install HPLIP package via apt"
FEATURE_DEFAULT="true"

run_feature() {
    sudo apt-get install -y hplip
}
