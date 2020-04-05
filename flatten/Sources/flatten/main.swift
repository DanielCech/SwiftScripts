import Foundation
import Files
import Moderator
import ScriptToolkit

let moderator = Moderator(description: "Flatten directory structure and make long file names.")
moderator.usageFormText = "flatten <params>"

let move = moderator.add(.option("m","move", description: "Move files from source folder"))
let inputDir = moderator.add(Argument<String?>
    .optionWithValue("input", name: "Input directory", description: "Input directory for processing"))
let outputDir = moderator.add(Argument<String?>
    .optionWithValue("output", name: "Output directory", description: "Output directory for result"))

do {
    try moderator.parse()
    guard let unwrappedInputDir = inputDir.value, let unwrappedOutputDir = outputDir.value else {
        print(moderator.usagetext)
        exit(0)
    }

    print("⌚️ Processing")
    let inputFolder = try Folder(path: unwrappedInputDir)
    try inputFolder.flattenFolderStructure(outputDir: unwrappedOutputDir, move: move.value)
    print("✅ Done")
}
catch {
    if let printableError = error as? PrintableError { print(printableError.errorDescription) }
    else {
        print(error.localizedDescription)
    }

    exit(Int32(error._code))
}
