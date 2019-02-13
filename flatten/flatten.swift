import Foundation
import Files
import Moderator
import ScriptToolkit

let moderator = Moderator(description: "Flatten directory structure and make long file names.")
let move = moderator.add(.option("m","move", description: "Move files from source folder"))
let inputDir = moderator.add(Argument<String?>
    .optionWithValue("input", name: "Input directory", description: "Input directory for processing"))
let outputDir = moderator.add(Argument<String?>
    .optionWithValue("output", name: "Output directory", description: "Output directory for result"))

do {
    try moderator.parse()
    if let inputFolder = inputDir.value, let outputFolder = outputDir.value {
        try flattenFolderStructure(inputDir: inputFolder, outputDir: outputFolder, move: move.value)
    }
    else {
        print(moderator.usagetext)
    }
}
catch let error as ArgumentError {
    print(error.errormessage)
    exit(Int32(error._code))
}
catch {
    print("flatten failed: \(error.localizedDescription)")
    exit(1)
}
