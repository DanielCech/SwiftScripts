import Foundation

import Foundation
import Files
import Moderator
import ScriptToolkit
import SwiftShell
import FileSmith

public func removeEmptyDirectories(in folder: Folder) throws {
    for subfolder in folder.subfolders {
        try removeEmptyDirectories(in: subfolder)
    }

    if folder.subfolders.count == 0 && folder.files.count == 0 {
        print("removed: \(folder.path)")
        try folder.delete()
    }
}

let moderator = Moderator(description: "Removes empty dirs in directory and its subdirectories")
let inputDir = moderator.add(Argument<String?>
    .optionWithValue("input", name: "Input directory", description: "Input directory for processing"))

do {
    try moderator.parse()
    if let inputFolder = inputDir.value {
        let folder = try Folder(path: inputFolder)
        
        print("⚙️ Processing")
        try removeEmptyDirectories(in: folder)
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
    main.stderror.print("sortPhotos failed: \(error.localizedDescription)")
    exit(1)
}
