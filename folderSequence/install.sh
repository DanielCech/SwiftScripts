#! /bin/bash
swift build
cp -rf .build/arm64-apple-macosx/debug/folderSequence Bin
cp -rf .build/arm64-apple-macosx/debug/folderSequence /usr/local/bin
