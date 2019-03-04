import Foundation

import Foundation
import Files
import Moderator
import ScriptToolkit
import SwiftShell
import FileSmith


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
    print(error.localizedDescription)
    exit(Int32(error._code))
}
