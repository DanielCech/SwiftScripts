import AppKit
import Files
import Foundation
import Moderator
import ScriptToolkit
import SwiftShell

extension File {
    func resizeImage(newName: String, size: CGSize) throws {
        let image: NSImage? = NSImage(contentsOfFile: path) ?? NSImage()
        let newSize = CGSize(width: size.width / 2, height: size.height / 2)

        let newImage = image.map { try? $0.copy(size: newSize) } ?? nil
        if let unwrappedNewImage = newImage {
            try unwrappedNewImage.savePNGRepresentationToURL(url: URL(fileURLWithPath: newName))
        }
    }
}

let moderator = Moderator(description: "prepareAppIcon - Prepare all required resolutions of iOS app icon")
moderator.usageFormText = "prepareappicon <params>"

let inFile = moderator.add(Argument<String?>
    .optionWithValue("input", name: "Input file", description: "PNG file preferably with 1024x1024 resolution"))

do {
    try moderator.parse()
    guard let unwrappedInFile = inFile.value else {
        print("prepareAppIcon - Prepare all required resolutions of iOS app icon\nUsage prepareIcon --input <file>")
        exit(0)
    }

    print("⚙️ Processing icons")
    let inputFile = try File(path: unwrappedInFile)

    // App list in iTunes
    try inputFile.resizeImage(newName: "iTunesArtwork.png", size: CGSize(width: 512, height: 512))

    // App list in iTunes for devices with retina display
    try inputFile.resizeImage(newName: "iTunesArtwork@2x.png", size: CGSize(width: 1024, height: 1024))

    // Home screen on iPhone/iPod Touch with retina display
    try inputFile.resizeImage(newName: "Icon-60@2x.png", size: CGSize(width: 120, height: 120))

    // Home screen on iPhone with retina HD display
    try inputFile.resizeImage(newName: "Icon-60@3x.png", size: CGSize(width: 180, height: 180))

    // Home screen on iPad
    try inputFile.resizeImage(newName: "Icon-76.png", size: CGSize(width: 76, height: 76))

    // Home screen on iPad with retina display
    try inputFile.resizeImage(newName: "Icon-76@2x.png", size: CGSize(width: 152, height: 152))

    // Home screen on iPad Pro
    try inputFile.resizeImage(newName: "Icon-83.5@2x.png", size: CGSize(width: 167, height: 167))

    // Spotlight
    try inputFile.resizeImage(newName: "Icon-Small-40.png", size: CGSize(width: 40, height: 40))

    // Spotlight on devices with retina display
    try inputFile.resizeImage(newName: "Icon-Small-40@2x.png", size: CGSize(width: 80, height: 80))

    // Spotlight on devices with retina HD display
    try inputFile.resizeImage(newName: "Icon-Small-40@3x.png", size: CGSize(width: 120, height: 120))

    // Settings
    try inputFile.resizeImage(newName: "Icon-Small.png", size: CGSize(width: 29, height: 29))

    // Settings on devices with retina display
    try inputFile.resizeImage(newName: "Icon-Small@2x.png", size: CGSize(width: 58, height: 58))

    // Settings on devices with retina HD display
    try inputFile.resizeImage(newName: "Icon-Small@3x.png", size: CGSize(width: 87, height: 87))

    print("✅ Done")
}
catch {
    if let printableError = error as? PrintableError { print(printableError.errorDescription) }
    else {
        print(error.localizedDescription)
    }

    exit(Int32(error._code))
}
