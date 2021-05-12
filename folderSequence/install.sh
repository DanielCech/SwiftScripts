#! /bin/bash
swift build
cp -rf .build/x86_64-apple-macosx/debug/folderSequence Bin
cp -rf .build/x86_64-apple-macosx/debug/folderSequence /usr/local/bin
