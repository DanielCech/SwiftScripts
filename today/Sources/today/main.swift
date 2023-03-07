import Files
import Foundation
import Moderator
import ScriptToolkit
import SwiftShell

let moderator = Moderator(description: "Creates a folder with today timestamp (YYYY-MM-DD)")
moderator.usageFormText = "today <parent folder>"

let dirs = moderator.add(Argument<String?>.singleArgument(name: "multiple").repeat())

do {
    try moderator.parse()
    guard !dirs.value.isEmpty else {
        print(moderator.usagetext)
        exit(0)
    }

    let dateString = ScriptToolkit.dateFormatter.string(from: Date())
    
    for item in dirs.value {
        let folder = try Folder(path: item)
        try folder.createSubfolder(named: dateString)
    }
}
catch {
    if let printableError = error as? PrintableError { print(printableError.errorDescription) }
    else {
        print(error.localizedDescription)
    }

    exit(Int32(error._code))
}
