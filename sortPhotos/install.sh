#! /bin/bash
swift build
cp -rf .build/x86_64-apple-macosx/debug/sortPhotos Bin
cp -rf .build/x86_64-apple-macosx/debug/sortPhotos /usr/local/bin
