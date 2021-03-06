import Foundation

import Files
import FileSmith
import Foundation
import Moderator
import ScriptToolkit
import SwiftShell

let moderator = Moderator(description: "Removes empty dirs in directory and its subdirectories")
moderator.usageFormText = "removeemptydirs <params>"

let inputDir = moderator.add(Argument<String?>
    .optionWithValue("input", name: "Input directory", description: "Input directory for processing"))

do {
    try moderator.parse()
    guard let inputFolder = inputDir.value else {
        print(moderator.usagetext)
        exit(0)
    }

    let folder = try Folder(path: inputFolder)

    print("⌚️ Processing")
    try folder.removeEmptyDirectories()
    print("✅ Done")
}
catch {
    if let printableError = error as? PrintableError { print(printableError.errorDescription) }
    else {
        print(error.localizedDescription)
    }

    exit(Int32(error._code))
}
