#! /bin/bash
swift build
cp -rf .build/arm64-apple-macosx/debug/sortPhotos Bin
cp -rf .build/arm64-apple-macosx/debug/sortPhotos /usr/local/bin
