#! /bin/bash
swift build
cp -rf .build/x86_64-apple-macosx/debug/practice Bin
cp -rf .build/x86_64-apple-macosx/debug/practice /usr/local/bin
