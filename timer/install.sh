#! /bin/bash
swift build
cp -rf .build/x86_64-apple-macosx/debug/timer Bin
cp -rf .build/x86_64-apple-macosx/debug/timer /usr/local/bin
