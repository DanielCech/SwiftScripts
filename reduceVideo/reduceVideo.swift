#!/usr/local/bin/marathon run

import Foundation
import Files
import Moderator
import ScriptToolkit
import SwiftShell

let moderator = Moderator(description: "ReduceVideo - Make the video file smaller for use with iPad")
moderator.usageFormText = "reducevideo <params> <files>"

let outputDirArgument = Argument<String?>
    .optionWithValue("output", name: "Output directory", description: "Output directory for generated pdfs")
    .default(main.currentdirectory.appendingPathComponent(path: "output"))
let outputDir = moderator.add(outputDirArgument)

let files = moderator.add(Argument<String?>.singleArgument(name: "multiple").repeat())


do {
    try moderator.parse()

    print("⌚️ Processing")

    try FileSystem().createFolderIfNeeded(at: outputDir.value)
    let outputFolder = try Folder(path: outputDir.value)

    for item in files.value {
        let file = try File(path: item)
        let newName = outputFolder.path.appendingPathComponent(path: file.name)
        try file.reduceVideo(newName: newName)
    }

    print("✅ Done")
}
catch {
    if let printableError = error as? PrintableError { print(printableError.errorDescription) }
    else {
        print(error.localizedDescription)
    }

    exit(Int32(error._code))
}
