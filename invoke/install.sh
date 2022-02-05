#! /bin/bash
swift build
cp -rf .build/arm64-apple-macosx/debug/invoke Bin
cp -rf .build/arm64-apple-macosx/debug/invoke /usr/local/bin
touch ~/invoke.sh
chmod +x ~/invoke.sh

