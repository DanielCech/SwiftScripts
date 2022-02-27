#! /bin/bash
swift build
cp -rf .build/arm64-apple-macosx/debug/renameEpisodes Bin
cp -rf .build/arm64-apple-macosx/debug/renameEpisodes /usr/local/bin
