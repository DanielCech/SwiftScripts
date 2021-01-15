#! /bin/bash
swift build
cp -rf .build/x86_64-apple-macosx/debug/colorPalette Bin
cp -rf .build/x86_64-apple-macosx/debug/colorPalette /usr/local/bin
