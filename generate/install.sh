#! /bin/bash
swift build
cp -rf .build/arm64-apple-macosx/debug/generate Bin
cp -rf .build/arm64-apple-macosx/debug/generate /usr/local/bin
