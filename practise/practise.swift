#!/usr/local/bin/marathon run

import Foundation
import Files
import Moderator
import ScriptToolkit
import SwiftShell


let moderator = Moderator(description: "Prepare song for practising - Add 5s silence at the beginning and set tempo to 75%, 90%, 100%")
moderator.usageFormText = "practise <params> <files>"

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
        print(file.name)
        try file.prepareSongForPractise(outputFolder: outputFolder)
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
