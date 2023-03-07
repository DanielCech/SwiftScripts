#! /bin/bash
swift build
cp -rf .build/arm64-apple-macosx/debug/today Bin
cp -rf .build/arm64-apple-macosx/debug/today /usr/local/bin
