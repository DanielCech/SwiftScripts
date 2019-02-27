import Foundation
import Files
import SwiftShell
import Moderator
import ScriptToolkit

func generateIcon(_ icon: String, size: CGSize, ribbon: String, title: String, scriptPath: String) throws {
    print(icon)
    guard
        let sourceRootPath = main.env["SRCROOT"],
        let buildPath = main.env["BUILT_PRODUCTS_DIR"],
        let unlocalizedResourcesPath = main.env["UNLOCALIZED_RESOURCES_FOLDER_PATH"]
        else {
            print("Missing environment variables")
            throw ScriptError.fileNotFound // fix!
    }

    print("  sourceRootPath: \(sourceRootPath)")
    print("  buildPath: \(buildPath)")
    print("  unlocalizedResourcesPath: \(unlocalizedResourcesPath)")

    guard let baseImageFile = try Folder(path: sourceRootPath).findFirstFile(name: icon) else {
        print("  Base file not found")
        throw ScriptError.fileNotFound
    }

    let targetPath = buildPath.appendingPathComponent(path: unlocalizedResourcesPath).appendingPathComponent(path: icon)
    print("  targetPath: \(targetPath)")

    let tempPath = "/tmp/.versionIcon"
    try FileSystem().createFolderIfNeeded(at: tempPath)

    let ribbonsDirPath = scriptPath.appendingPathComponent(path: "Ribbons")
    let ribbonPath = ribbonsDirPath.appendingPathComponent(path: ribbon)

    let titlesDirPath = scriptPath.appendingPathComponent(path: "Titles")
    let titlePath = titlesDirPath.appendingPathComponent(path: title)

    print("  Resizing ribbon")
    let resizedRibbonPath = tempPath.appendingPathComponent(path: "resizedRibbon.png")
    try File(path: ribbonPath).resizeImage(newName: resizedRibbonPath, size: size)

    print("  Resizing title")
    let resizedTitlePath = tempPath.appendingPathComponent(path: "resizedTitle.png")
    try File(path: titlePath).resizeImage(newName: resizedTitlePath, size: size)

    print("  Annotating")
    let annotatedFilePath = tempPath.appendingPathComponent(path: "annotated.png")
    run(ScriptToolkit.convertPath, baseImageFile.path, "-fill", "white", "-font", "Impact", "-pointsize", String(Int(size.width * 0.15)), "-gravity", "south", "-annotate", "0", "Hello", annotatedFilePath)

    print("  Annotating with ribbon")
    let annotatedRibbonFilePath = tempPath.appendingPathComponent(path: "annotatedRibbon.png")
    run(ScriptToolkit.compositePath, resizedRibbonPath, annotatedFilePath, annotatedRibbonFilePath)

    print("  Annotating with ribbon and title")
    run(ScriptToolkit.compositePath, resizedTitlePath, annotatedRibbonFilePath, targetPath)
}

let moderator = Moderator(description: "VersionIcon prepares iOS icon with ribbon, text and version info")
let ribbon = moderator.add(Argument<String?>
    .optionWithValue("ribbon", name: "Icon ribbon color", description: "Icon ribbon color"))
let title = moderator.add(Argument<String?>
    .optionWithValue("title", name: "Icon ribbon title", description: "Icon ribbon title"))
let scriptPath = moderator.add(Argument<String?>
    .optionWithValue("script", name: "VersionIcon script path", description: "VersionIcon script path"))

print("Started")

do {
    try moderator.parse()
    guard let unwrappedRibbon = ribbon.value, let unwrappedTitle = title.value, let unwrappedScriptPath = scriptPath.value else {
        print(moderator.usagetext)
        exit(0)
    }

    print("⌚️ Processing")
    try generateIcon("AppIcon60x60@2x.png", size: CGSize(width: 120, height: 120), ribbon: unwrappedRibbon, title: unwrappedTitle, scriptPath: unwrappedScriptPath)
    try generateIcon("AppIcon60x60@3x.png", size: CGSize(width: 180, height: 180), ribbon: unwrappedRibbon, title: unwrappedTitle, scriptPath: unwrappedScriptPath)
    try generateIcon("AppIcon76x76~ipad.png", size: CGSize(width: 76, height: 76), ribbon: unwrappedRibbon, title: unwrappedTitle, scriptPath: unwrappedScriptPath)
    try generateIcon("AppIcon76x76@2x~ipad.png", size: CGSize(width: 152, height: 152), ribbon: unwrappedRibbon, title: unwrappedTitle, scriptPath: unwrappedScriptPath)
    print("✅ Done")
}
catch let error as ArgumentError {
    print("💥 versionIcon failed: \(error.errormessage)")
    exit(Int32(error._code))
}
catch {
    print("💥 versionIcon failed: \(error.localizedDescription)")
    exit(1)
}
