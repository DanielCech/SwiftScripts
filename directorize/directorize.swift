#!/usr/local/bin/marathon run

import Foundation
import Files
import Moderator
import ScriptToolkit
import SwiftShell

let moderator = Moderator(description: "Directorize - put files to separate directories with the name of file (without extension)")

let outputDirArgument = Argument<String?>
    .optionWithValue("output", name: "Output directory", description: "Output directory for generated images")
    .default("./output")
let outputDir = moderator.add(outputDirArgument)

let moveFiles = moderator.add(.option("m","move", description: "Move files instead of copying"))

let files = moderator.add(Argument<String?>.singleArgument(name: "multiple").repeat())


do {
    try moderator.parse()

    guard !files.value.isEmpty else {
        print(moderator.usagetext)
        exit(0)
    }

    print("⌚️ Processing")

    try FileSystem().createFolderIfNeeded(at: outputDir.value)

    for item in files.value {
        let file = try File(path: item)
        print(file.name)

        let newPath = outputDir.value.appendingPathComponent(path: file.nameExcludingExtension)
        try FileSystem().createFolderIfNeeded(at: newPath)
        let newFolder = try Folder(path: newPath)

        if moveFiles.value {
            try file.move(to: newFolder)
        }
        else {
            try file.copy(to: newFolder)
        }
    }

    print("✅ Done")
}
catch let error as ArgumentError {
    print("💥 directorize failed: \(error.errormessage)")
    exit(Int32(error._code))
}
catch {
    print("💥 directorize failed: \(error.localizedDescription)")
    exit(1)
}
