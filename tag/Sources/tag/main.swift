import Foundation
import Files
import SwiftShell
import Moderator
import ScriptToolkit

let moderator = Moderator(description: "Tag file or directory with timestamp (YYYY-MM-DDc)")
moderator.usageFormText = "tag <params> <files or dirs>"

let onCopy = moderator.add(.option("c","copy", description: "Tags copy of the file"))
let filesAndDirs = moderator.add(Argument<String?>.singleArgument(name: "multiple").repeat())

do {
    try moderator.parse()
    guard !filesAndDirs.value.isEmpty else {
        print(moderator.usagetext)
        exit(0)
    }
    
    for item in filesAndDirs.value {

        switch FileManager.default.locationKind(at: item) {
        case .file:
            let file = try File(path: item)
            try file.tag(copy: onCopy.value)

        case .folder:
            let folder = try Folder(path: item)
            try folder.tag(copy: onCopy.value)
        }
    }
}
catch {
    if let printableError = error as? PrintableError { print(printableError.errorDescription) }
    else {
        print(error.localizedDescription)
    }

    exit(Int32(error._code))
}
