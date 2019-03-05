import Foundation
import AppKit
import Files
import SwiftShell
import Moderator
import ScriptToolkit

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
