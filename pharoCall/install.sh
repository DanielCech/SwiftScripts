#! /bin/bash
swift build
cp -rf .build/arm64-apple-macosx/debug/pharoCall Bin
cp -rf .build/arm64-apple-macosx/debug/pharoCall /usr/local/bin
