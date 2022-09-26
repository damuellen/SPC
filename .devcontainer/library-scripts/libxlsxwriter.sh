#!/usr/bin/env bash
sudo apt update
sudo apt install make build-essential
echo "Install libxlsxwriter"
cd /tmp
git clone --single-branch -b RELEASE_1.1.4 https://github.com/jmcnamara/libxlsxwriter --quiet
cd libxlsxwriter
make
sudo make install
sudo ldconfig
cd ../
rm -rf /tmp/libxlsxwriter