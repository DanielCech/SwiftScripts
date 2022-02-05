#! /bin/bash
swift build
cp -rf .build/arm64-apple-macosx/debug/colorPalette Bin
cp -rf .build/arm64-apple-macosx/debug/colorPalette /usr/local/bin
