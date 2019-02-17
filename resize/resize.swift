#!/usr/local/bin/marathon run

import Foundation
import Files
import Moderator
import ScriptToolkit
import SwiftShell

let moderator = Moderator(description: "Resize image to particular size in @1x, @2x and @2x")

let sizeArgument = Argument<String?>
    .optionWithValue("size", name: "Size of image in in WIDTHxHEIGHT format", description: "Resulting size in selected resolution")
var size = moderator.add(sizeArgument)

let outputDirArgument = Argument<String?>
    .optionWithValue("output", name: "Output directory", description: "Output directory for generated images")
    .default("./output")
let outputDir = moderator.add(outputDirArgument)

let interactive = moderator.add(.option("i","interactive", description: "Interactive mode. Script will ask about missing important parameters"))
let files = moderator.add(Argument<String?>.singleArgument(name: "multiple").repeat())



do {
    try moderator.parse()

    guard !files.value.isEmpty else {
        print(moderator.usagetext)
        exit(0)
    }

    print("⌚️ Processing")

    if interactive.value {
        try askForMissingParams([(sizeArgument, size)])
    }

    guard let unwrappedSize = size.value else {
        print(moderator.usagetext)
        exit(0)
    }

    let dimensions = unwrappedSize.trimmingCharacters(in: [" "]).split(separator: "x")
    if dimensions.count != 2 {
        throw ArgumentError(errormessage: "Invalid size argument")
    }

    guard let width = Int(dimensions[0]), let height = Int(dimensions[1]) else { throw ArgumentError(errormessage: "Invalid size argument") }

    try FileSystem().createFolderIfNeeded(at: outputDir.value)

    for item in files.value {
        try File(path: item).resizeAt123x(width: width, height: height, outputDir: Folder(path: outputDir.value))
    }

    print("✅ Done")
}
catch let error as ArgumentError {
    main.stderror.print(error.errormessage)
    exit(Int32(error._code))
}
catch {
    main.stderror.print("resize failed: \(error.localizedDescription)")
    exit(1)
}
