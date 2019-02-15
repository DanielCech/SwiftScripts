#!/usr/local/bin/marathon run

import Foundation
import Files
import Moderator
import ScriptToolkit
import SwiftShell

let moderator = Moderator(description: "Prepare song for practising - Add 5s silence at the beginning and set tempo to 75%, 90%, 100%")

let outputDirArgument = Argument<String?>
    .optionWithValue("output", name: "Output directory", description: "Output directory for generated images")
    .default("./output")
let outputDir = moderator.add(outputDirArgument)

let files = moderator.add(Argument<String?>.singleArgument(name: "multiple").repeat())



do {
    try moderator.parse()

    if !files.value.isEmpty {

        print("⌚️ Processing")

        try FileSystem().createFolderIfNeeded(at: outputDir.value)

        for item in files.value {
            let file = try File(path: item)
            try file.slowDownAudio(newFile: file.nameExcludingExtension + "@75." + file.extension, amount: 0.75)
            try file.slowDownAudio(newFile: file.nameExcludingExtension + "@90." + file.extension, amount: 0.9)
        }

        print("✅ Done")
    }
    else {
        print(moderator.usagetext)
    }
}
catch let error as ArgumentError {
    main.stderror.print(error.errormessage)
    exit(Int32(error._code))
}
catch {
    main.stderror.print("resize failed: \(error.localizedDescription)")
    exit(1)
}
