#! /bin/bash
swift build
cp -rf .build/arm64-apple-macosx/debug/tag Bin
cp -rf .build/arm64-apple-macosx/debug/tag /usr/local/bin
