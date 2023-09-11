#! /bin/bash
swift build
cp -rf .build/arm64-apple-macosx/debug/pharoCollect Bin
cp -rf .build/arm64-apple-macosx/debug/pharoCollect /usr/local/bin
