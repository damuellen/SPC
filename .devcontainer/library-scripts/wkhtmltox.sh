#!/usr/bin/env bash
echo "Install wkhtmltopdf"
cd /tmp
wget https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6.1-3/wkhtmltox_0.12.6.1-3.jammy_amd64.deb
export DEBIAN_FRONTEND=noninteractive
sudo apt install -f /tmp/wkhtmltox_0.12.6.1-3.jammy_amd64.deb
sudo apt update
sudo apt install xfonts-base xfonts-75dpi
sudo apt install -f /tmp/wkhtmltox_0.12.6.1-3.jammy_amd64.deb
cd ../
rm -rf /tmp/wkhtmltox_0.12.6.1-3.jammy_amd64.deb
