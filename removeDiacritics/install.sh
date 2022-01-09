#! /bin/bash
swift build
cp -rf .build/x86_64-apple-macosx/release/removeDiacritics Bin
cp -rf .build/x86_64-apple-macosx/release/removeDiacritics /usr/local/bin
