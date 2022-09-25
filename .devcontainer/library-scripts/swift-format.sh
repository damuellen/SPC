#!/usr/bin/env bash
echo "Install swift-format"
cd /tmp
git clone --single-branch -b 0.50700.0 https://github.com/apple/swift-format.git --quiet
cd swift-format
swift build -c release --product swift-format
cp .build/release/swift-format /usr/local/bin/swift-format
cd ../
rm -rf /tmp/swift-format
