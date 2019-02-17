#!/usr/local/bin/marathon run

import Foundation
import Files
import Moderator
import ScriptToolkit
import SwiftShell




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
        print(file.name + ":")

        let originalWavFile: File
        if let ext = file.extension, ext.lowercased() != "wav" {
            originalWavFile = try file.convertToWav(newName: "wav-file.wav")
        }
        else {
            originalWavFile = file
        }

        let file75 = try originalWavFile.slowDownAudio(newName: "tempo-75.wav", percent: 0.75)
        let file90 = try originalWavFile.slowDownAudio(newName: "tempo-90.wav", percent: 0.9)

        let silencedFile75 = try file75.addSilence(newName: "silence-75.wav")
        let silencedFile90 = try file90.addSilence(newName: "silence-90.wav")
        let silencedFile100 = try originalWavFile.addSilence(newName: "silence-100.wav")

        let silencedM4AFile75 = try silencedFile75.convertToM4A(newName: file.nameExcludingExtension + "@75.m4a")
        let silencedM4AFile90 = try silencedFile90.convertToM4A(newName: file.nameExcludingExtension + "@90.m4a")
        let silencedM4AFile100 = try silencedFile100.convertToM4A(newName: file.nameExcludingExtension + "@100.m4a")

        // Move result to output dir
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

    print("✅ Done")
}
catch let error as ArgumentError {
    main.stderror.print(error.errormessage)
    exit(Int32(error._code))
}
catch {
    main.stderror.print("practise failed: \(error.localizedDescription)")
    exit(1)
}
