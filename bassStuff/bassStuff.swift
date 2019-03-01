#!/usr/local/bin/marathon run

import Foundation
import Files
import Moderator
import ScriptToolkit
import SwiftShell


func processForScore(inputFolder: Folder, outputFolder: Folder) throws {
    for file in inputFolder.files {
        let newFileName = outputFolder.path.appendingPathComponent(path: file.name)
        try file.cropPDF(newName: newFileName, insets: NSEdgeInsets(top: 5, left: 5, bottom: 5, right: 5), overwrite: false)
    }
}

func processSongs(inputFolder: Folder, outputFolder: Folder) throws {
    for file in inputFolder.files {
        try file.prepareSongForPractise(outputFolder: outputFolder, overwrite: false)
    }
}

func processVideos(inputFolder: Folder, outputFolder: Folder) throws {
    for file in inputFolder.files {
        let newName = outputFolder.path.appendingPathComponent(path: file.name)
        try file.reduceVideo(newName: newName, overwrite: false)
    }
}

let moderator = Moderator(description: "BassStuff - prepare materials for practising bass guitar")

let inputDirArgument = Argument<String?>
    .optionWithValue("input", name: "Input directory", description: "Input directory")
let inputDir = moderator.add(inputDirArgument)

let outputDirArgument = Argument<String?>
    .optionWithValue("output", name: "Output directory", description: "Output directory for generated images")
let outputDir = moderator.add(outputDirArgument)

do {
    try moderator.parse(["--input", "/Users/dan/Documents/[Temp]/[iPadProcessing]", "--output", "/Users/dan/Documents/[Temp]/[iPad]"])

    guard let unwrappedInputDir = inputDir.value, let unwrappedOutputDir = outputDir.value else {
        print(moderator.usagetext)
        exit(0)
    }

    print("⌚️ Processing")

    // Input folders
    let pdfFolder = try Folder(path: unwrappedInputDir.appendingPathComponent(path: "PDF"))
    let pdfFlattenedFolder = try Folder(path: unwrappedInputDir.appendingPathComponent(path: "PDF-Flattened"))
    let songsFolder = try Folder(path: unwrappedInputDir.appendingPathComponent(path: "Songs"))
    let videosFolder = try Folder(path: unwrappedInputDir.appendingPathComponent(path: "Videos"))

    // Output folders
    let forscorePath = unwrappedOutputDir.appendingPathComponent(path: "ForScore")
    let nPlayerPath = unwrappedOutputDir.appendingPathComponent(path: "nPlayer")
    let playerExtremePath = unwrappedOutputDir.appendingPathComponent(path: "PlayerExtreme")

    try FileSystem().createFolderIfNeeded(at: forscorePath)
    try FileSystem().createFolderIfNeeded(at: nPlayerPath)
    try FileSystem().createFolderIfNeeded(at: playerExtremePath)

    let forscoreFolder = try Folder(path: forscorePath)
    let nPlayerFolder = try Folder(path: nPlayerPath)
    let playerExtremeFolder = try Folder(path: playerExtremePath)

    print("🧩 Flattening PDFs")

    // Flatten PDFs
    try pdfFlattenedFolder.empty()
    try pdfFolder.flattenFolderStructure(outputDir: pdfFlattenedFolder.path, move: false)

    print("🔪 Cropping PDFs")

    // Crop PDFs
    try processForScore(inputFolder: pdfFlattenedFolder, outputFolder: forscoreFolder)

    print("🎼 Processing songs")

    // Process Songs using SOX
    try processSongs(inputFolder: songsFolder, outputFolder: nPlayerFolder)

    print("🎥 Processing videos")

    // Process Videos
    try processVideos(inputFolder: videosFolder, outputFolder: playerExtremeFolder)

    print("✅ Done")
}
catch let error as ArgumentError {
    main.stderror.print(error.errormessage)
    exit(Int32(error._code))
}
catch {
    main.stderror.print("BassStuff failed: \(error.localizedDescription)")
    exit(1)
}
