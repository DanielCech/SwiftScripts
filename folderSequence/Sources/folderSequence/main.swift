import Foundation

import Files
import Foundation
import Moderator
import ScriptToolkit
import SwiftShell

let moderator = Moderator(description: "Creates a sequence of folders")
moderator.usageFormText = "foldersequence <params>"

let fromArgument = moderator.add(Argument<String?>
    .optionWithValue("from", name: "Initial number", description: ""))

let toArgument = moderator.add(Argument<String?>
    .optionWithValue("to", name: "Final number", description: ""))

do {
    try moderator.parse()
    
    guard
        let fromString = fromArgument.value,
        let from = Int(fromString),
        let toString = toArgument.value,
        let to = Int(toString)
    else {
        print(moderator.usagetext)
        exit(0)
    }

    print("⌚️ Processing")

    

    for index in from ... to {
        let dirName = String(format: "%03d", index)
        try Folder.current.createSubfolder(named: dirName)
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
