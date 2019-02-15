#!/usr/local/bin/marathon run

import Foundation
import Files
import SwiftShell
import Moderator
import ScriptToolkit

let moderator = Moderator(description: "Prepare all required resolutions of iOS app icon")
let inFile = moderator.add(Argument<String?>.singleArgument(name: "input"))

do {
    try moderator.parse()
    if let inputFile = inFile.value {
        print("⚙️ Processing icons")

        resizeImage(original: inputFile, newName: "iPhoneNotification-20x20@2x.png", size: CGSize(width: 40, height: 40))
        resizeImage(original: inputFile, newName: "iPhoneNotification-20x20@3x.png", size: CGSize(width: 60, height: 60))
        resizeImage(original: inputFile, newName: "iPhoneSpotlightSettings-29x29@2x.png", size: CGSize(width: 58, height: 58))
        resizeImage(original: inputFile, newName: "iPhoneSpotlightSettings-29x29@3x.png", size: CGSize(width: 87, height: 87))
        resizeImage(original: inputFile, newName: "iPhoneSpotlight-40x40@2x.png", size: CGSize(width: 80, height: 80))
        resizeImage(original: inputFile, newName: "iPhoneSpotlight-40x40@3x.png", size: CGSize(width: 120, height: 120))
        resizeImage(original: inputFile, newName: "iPhoneApp-60x60@2x.png", size: CGSize(width: 120, height: 120))
        resizeImage(original: inputFile, newName: "iPhoneApp-60x60@3x.png", size: CGSize(width: 180, height: 180))
        resizeImage(original: inputFile, newName: "iPadNotification-20x20.png", size: CGSize(width: 20, height: 20))
        resizeImage(original: inputFile, newName: "iPadNotification-20x20@2x.png", size: CGSize(width: 40, height: 40))
        resizeImage(original: inputFile, newName: "iPadSettings-29x29.png", size: CGSize(width: 29, height: 29))
        resizeImage(original: inputFile, newName: "iPadSettings-29x29@2x.png", size: CGSize(width: 58, height: 58))
        resizeImage(original: inputFile, newName: "iPadSpotlight-40x40.png", size: CGSize(width: 40, height: 40))
        resizeImage(original: inputFile, newName: "iPadSpotlight-40x40@2x.png", size: CGSize(width: 80, height: 80))
        resizeImage(original: inputFile, newName: "iPadApp-76x76.png", size: CGSize(width: 76, height: 76))
        resizeImage(original: inputFile, newName: "iPadProApp-83,5x83,5@2x.png", size: CGSize(width: 167, height: 167))
        resizeImage(original: inputFile, newName: "iPhoneDocument-22x29.png", size: CGSize(width: 22, height: 29))
        resizeImage(original: inputFile, newName: "iPhoneDocument-22x29@2x.png", size: CGSize(width: 44, height: 58))
        resizeImage(original: inputFile, newName: "iPadDocument-64x64.png", size: CGSize(width: 64, height: 64))
        resizeImage(original: inputFile, newName: "iPadDocument-320x320.png", size: CGSize(width: 320, height: 230))

        print("✅ Done")
    }
    else {
        print(moderator.usagetext)
    }
}
catch let error as ArgumentError {
    print(error.errormessage)
    exit(Int32(error._code))
}
catch {
    print("prepareAppIcon failed: \(error.localizedDescription)")
    exit(1)
}
