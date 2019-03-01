#!/usr/local/bin/marathon run

import Foundation
import Files
import Moderator
import ScriptToolkit
import SwiftShell

extension File {
    func prepareSongForPractise(outputFolder: Folder) throws {
        print(name + ":")

        let originalWavFile: File
        if let ext = `extension`, ext.lowercased() != "wav" {
            print("  Converting to wav")
            originalWavFile = try convertToWav(newName: "wav-file.wav")
        }
        else {
            originalWavFile = self
        }

        print("  Converting to 75% speed")
        let file75 = try originalWavFile.slowDownAudio(newName: "tempo-75.wav", percent: 0.75)
        print("  Converting to 90% speed")
        let file90 = try originalWavFile.slowDownAudio(newName: "tempo-90.wav", percent: 0.9)

        print("  Adding initial silence to 75% speed file")
        let silencedFile75 = try file75.addSilence(newName: "silence-75.wav")
        print("  Adding initial silence to 90% speed file")
        let silencedFile90 = try file90.addSilence(newName: "silence-90.wav")
        print("  Adding initial silence to 100% speed file")
        let silencedFile100 = try originalWavFile.addSilence(newName: "silence-100.wav")

        print("  Converting to M4A")
        let silencedM4AFile75 = try silencedFile75.convertToM4A(newName: nameExcludingExtension + "@75.m4a")
        let silencedM4AFile90 = try silencedFile90.convertToM4A(newName: nameExcludingExtension + "@90.m4a")
        let silencedM4AFile100 = try silencedFile100.convertToM4A(newName: nameExcludingExtension + "@100.m4a")

        // Move result to output dir
        print("  Moving to destination folder")
        try silencedM4AFile75.move(to: outputFolder)
        try silencedM4AFile90.move(to: outputFolder)
        try silencedM4AFile100.move(to: outputFolder)

        // Clean up
        try originalWavFile.delete()
        try file75.delete()
        try file90.delete()
        try silencedFile75.delete()
        try silencedFile90.delete()
        try silencedFile100.delete()
    }
}


let moderator = Moderator(description: "Prepare song for practising - Add 5s silence at the beginning and set tempo to 75%, 90%, 100%")

let outputDirArgument = Argument<String?>
    .optionWithValue("output", name: "Output directory", description: "Output directory for generated images")
    .default(main.currentdirectory.appendingPathComponent(path: "output"))
let outputDir = moderator.add(outputDirArgument)

let files = moderator.add(Argument<String?>.singleArgument(name: "multiple").repeat())


do {
    try moderator.parse()

    guard !files.value.isEmpty else {
        print(moderator.usagetext)
        exit(0)
    }

    print("⌚️ Processing")

    try FileSystem().createFolderIfNeeded(at: outputDir.value)
    let outputFolder = try Folder(path: outputDir.value)

    for item in files.value {
        let file = try File(path: item)
        try file.prepareSongForPractise(outputFolder: outputFolder)
    }

    print("✅ Done")
}
catch {
    print(error.localizedDescription)
    exit(Int32(error._code))
}
