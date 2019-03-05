import Foundation
import AppKit
import Files
import SwiftShell
import Moderator
import ScriptToolkit

// Based on: https://gist.github.com/MaciejGad/11d8469b218817290ee77012edb46608

extension NSImage {

    /// Returns the height of the current image.
    var height: CGFloat {
        return self.size.height
    }

    /// Returns the width of the current image.
    var width: CGFloat {
        return self.size.width
    }

    /// Returns a png representation of the current image.
    var PNGRepresentation: Data? {
        if let tiff = self.tiffRepresentation, let tiffData = NSBitmapImageRep(data: tiff) {
            return tiffData.representation(using: .png, properties: [:])
        }

        return nil
    }

    ///  Copies the current image and resizes it to the given size.
    ///
    ///  - parameter size: The size of the new image.
    ///
    ///  - returns: The resized copy of the given image.
    func copy(size: NSSize) throws -> NSImage {
        // Create a new rect with given width and height
        let frame = NSMakeRect(0, 0, size.width, size.height)

        // Get the best representation for the given size.
        guard let rep = self.bestRepresentation(for: frame, context: nil, hints: nil) else {
            throw ScriptError.generalError(message: "Unable to resize image")
        }

        // Create an empty image with the given size.
        let img = NSImage(size: size)

        // Set the drawing context and make sure to remove the focus before returning.
        img.lockFocus()
        defer { img.unlockFocus() }

        // Draw the new image
        if rep.draw(in: frame) {
            return img
        }

        // Return nil in case something went wrong.
        throw ScriptError.generalError(message: "Unable to resize image")
    }

    ///  Saves the PNG representation of the current image to the HD.
    ///
    /// - parameter url: The location url to which to write the png file.
    func savePNGRepresentationToURL(url: URL) throws {
        if let png = self.PNGRepresentation {
            try png.write(to: url, options: .atomicWrite)
        }
    }

    func combine(withImage image: NSImage) throws -> NSImage {
        guard
            let firstImageData = image.tiffRepresentation,
            let firstImage = CIImage(data: firstImageData),
            let secondImageData = tiffRepresentation,
            let secondImage = CIImage(data: secondImageData)
        else {
            throw ScriptError.generalError(message: "Image processing error")
        }

        let filter = CIFilter(name: "CISourceOverCompositing")!
        filter.setDefaults()

        filter.setValue(firstImage, forKey: "inputImage")
        filter.setValue(secondImage, forKey: "inputBackgroundImage")

        let resultImage = filter.outputImage

        let rep = NSCIImageRep(ciImage: resultImage!)
        let finalResult = NSImage(size: rep.size)
        finalResult.addRepresentation(rep)

        return finalResult
    }

    func image(withText text: String, attributes: [NSAttributedString.Key: Any]) -> NSImage {
        let image = self
        let text = text as NSString
        let options: NSString.DrawingOptions = [.usesLineFragmentOrigin, .usesFontLeading]

        let textSize = text.boundingRect(with: image.size, options: options, attributes: attributes).size

        let x = (image.size.width - textSize.width) / 2
        let y = (image.size.height - textSize.height) / 2
        let point = NSMakePoint(x, y * 0.2)

        image.lockFocus()
        text.draw(at: point, withAttributes: attributes)
        image.unlockFocus()

        return image
    }

    func annotate(text: String, size: CGFloat, fill: NSColor, stroke: NSColor) -> NSImage {

        // Solid color text
        let fillText = image(
            withText: text,
            attributes: [
                .foregroundColor: fill,
                .font: NSFont(name: "Impact", size: size)!
            ])

        // Add strokes
        return fillText.image(
            withText: text,
            attributes: [
                .foregroundColor: fill,
                .strokeColor: stroke,
                .strokeWidth: 1,
                .font: NSFont(name: "Impact", size: size)!
            ])
    }
}



func generateIcon(_ icon: String, size: CGSize, ribbon: String, title: String, fillColor: String, strokeColor: String, original: Bool, scriptPath: String) throws {
    print(icon)
    guard
        let sourceRootPath = main.env["SRCROOT"],
        let projectDir = main.env["PROJECT_DIR"],
        let infoPlistFile = main.env["INFOPLIST_FILE"]
        else {
            print("Missing environment variables")
            throw ScriptError.moreInfoNeeded(message: "Missing required environment variables: SRCROOT, PROJECT_DIR, INFOPLIST_FILE")
    }

//    let sourceRootPath = "/Users/dan/Documents/[Development]/[Projects]/RoboticArmApp"
//    let projectDir = "/Users/dan/Documents/[Development]/[Projects]/RoboticArmApp"
//    let infoPlistFile = "Arm/Info.plist"

    print("  sourceRootPath: \(sourceRootPath)")
    print("  projectDir: \(projectDir)")
    print("  infoPlistFile: \(infoPlistFile)")

    let versionNumberResult = run("/usr/libexec/PlistBuddy", "-c", "Print CFBundleShortVersionString", projectDir.appendingPathComponent(path: infoPlistFile))
    let buildNumberResult = run("/usr/libexec/PlistBuddy", "-c", "Print CFBundleVersion", projectDir.appendingPathComponent(path: infoPlistFile))
    let version = "\(versionNumberResult.stdout) - \(buildNumberResult.stdout)"

    let sourceFolder = try Folder(path: sourceRootPath)

    guard let originalAppIconFolder = sourceFolder.findFirstFolder(name: "AppIconOriginal.appiconset") else {
        throw ScriptError.folderNotFound(message: "AppIconOriginal.appiconset - source icon asset for modifications")
    }

    guard let baseImageFile = originalAppIconFolder.findFirstFile(name: icon) else {
        throw ScriptError.fileNotFound(message: "\(icon) in AppIconOriginal.appiconset folder")
    }

    guard let appIconFolder = sourceFolder.findFirstFolder(name: "AppIcon.appiconset") else {
        throw ScriptError.folderNotFound(message: "AppIcon.appiconset - icon asset folder")
    }

    let targetPath = appIconFolder.path.appendingPathComponent(path: icon)
    print("  targetPath: \(targetPath)")

    if original {
        try FileManager.default.removeItem(atPath: targetPath)
        try baseImageFile.copy(to: appIconFolder)
    }
    else {
        let newSize = CGSize(width: size.width / 2, height: size.height / 2)

        let ribbonsDirPath = scriptPath.appendingPathComponent(path: "Ribbons")
        let ribbonPath = ribbonsDirPath.appendingPathComponent(path: ribbon)

        let titlesDirPath = scriptPath.appendingPathComponent(path: "Titles")
        let titlePath = titlesDirPath.appendingPathComponent(path: title)

        print("  Resizing ribbon")
        guard let ribbonImage = NSImage(contentsOfFile: ribbonPath) else { throw ScriptError.generalError(message: "Invalid image file") }
        let resizedRibbonImage = try ribbonImage.copy(size: newSize)

        print("  Resizing title")
        guard let titleImage = NSImage(contentsOfFile: titlePath) else { throw ScriptError.generalError(message: "Invalid image file") }
        let resizedTitleImage = try titleImage.copy(size: newSize)

        let iconImageData = try Data(contentsOf: URL(fileURLWithPath: baseImageFile.path))
        guard let iconImage = NSImage(data: iconImageData) else { throw ScriptError.generalError(message: "Invalid image file") }

        let combinedImage = try iconImage.combine(withImage: resizedRibbonImage).combine(withImage: resizedTitleImage)

        print("  Annotating")
        let resultImage = combinedImage.annotate(text: version, size: size.width * 0.2, fill: .white, stroke: .black)

        let resizedIcon = try resultImage.copy(size: newSize)

        try resizedIcon.savePNGRepresentationToURL(url: URL(fileURLWithPath: targetPath))
    }
}

let moderator = Moderator(description: "VersionIcon prepares iOS icon with ribbon, text and version info")
moderator.usageFormText = "versionIcon <params>"

let ribbon = moderator.add(Argument<String?>
    .optionWithValue("ribbon", name: "Icon ribbon color", description: "Name of PNG file in Ribbons folder"))
let title = moderator.add(Argument<String?>
    .optionWithValue("title", name: "Icon ribbon title", description: "Name of PNG file in Titles folder"))
let titleFillColor = moderator.add(Argument<String?>
    .optionWithValue("fillcolor", name: "Title fill color", description: "The fill color of version title").default("white"))
let titleStrokeColor = moderator.add(Argument<String?>
    .optionWithValue("strokecolor", name: "Title stroke color", description: "The stroke color of version title").default("black"))
let scriptPath = moderator.add(Argument<String?>
    .optionWithValue("script", name: "VersionIcon script path", description: "Path where Ribbons and Titles folders are located"))
let iPhone = moderator.add(.option("iphone", description: "Generate iPhone icons"))
let iPad = moderator.add(.option("ipad", description: "Generate iPad icons"))
let original = moderator.add(.option("original", description: "Use original icon with no modifications (for production)"))

do {
    // try moderator.parse(["--ribbon", "Red.png", "--title", "Devel.png", "--script", "/Users/dan/Documents/[Development]/[Projects]/SwiftScripts/versionIcon", "--iphone"])
    try moderator.parse()
    guard let unwrappedRibbon = ribbon.value, let unwrappedTitle = title.value, let unwrappedScriptPath = scriptPath.value else {
        print(moderator.usagetext)
        exit(0)
    }

    print("⌚️ Processing")
    
    if iPhone.value {
        try generateIcon(
            "AppIcon60x60@2x.png",
            size: CGSize(width: 120, height: 120),
            ribbon: unwrappedRibbon,
            title: unwrappedTitle,
            fillColor: titleFillColor.value,
            strokeColor: titleStrokeColor.value,
            original: original.value,
            scriptPath: unwrappedScriptPath
        )

        try generateIcon(
            "AppIcon60x60@3x.png",
            size: CGSize(width: 180, height: 180),
            ribbon: unwrappedRibbon,
            title: unwrappedTitle,
            fillColor: titleFillColor.value,
            strokeColor: titleStrokeColor.value,
            original: original.value,
            scriptPath: unwrappedScriptPath
        )
    }

    if iPad.value {
        try generateIcon(
            "AppIcon76x76~ipad.png",
            size: CGSize(width: 76, height: 76),
            ribbon: unwrappedRibbon,
            title: unwrappedTitle,
            fillColor: titleFillColor.value,
            strokeColor: titleStrokeColor.value,
            original: original.value,
            scriptPath: unwrappedScriptPath
        )

        try generateIcon(
            "AppIcon76x76@2x~ipad.png",
            size: CGSize(width: 152, height: 152),
            ribbon: unwrappedRibbon,
            title: unwrappedTitle,
            fillColor: titleFillColor.value,
            strokeColor: titleStrokeColor.value,
            original: original.value,
            scriptPath: unwrappedScriptPath
        )
    }

    print("✅ Done")
}
catch {
    print(error.localizedDescription)
    exit(Int32(error._code))
}
