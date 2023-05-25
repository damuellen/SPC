#!/usr/bin/env bash
echo "Install wkhtmltopdf"
cd /tmp
wget https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6.1-3/wkhtmltox_0.12.6.1-3.jammy_amd64.deb
sudo apt install -y -f /tmp/wkhtmltox_0.12.6.1-3.jammy_amd64.deb
sudo apt update
sudo apt install -y xfonts-base xfonts-75dpi
sudo apt install -y -f /tmp/wkhtmltox_0.12.6.1-3.jammy_amd64.deb
cd ../
rm -rf /tmp/wkhtmltox_0.12.6.1-3.jammy_amd64.deb
