import Foundation

import Files
import FileSmith
import Foundation
import Moderator
import ScriptToolkit
import SwiftShell

let moderator = Moderator(description: "Sorts folder of JPEG images to folders using EXIF metadata. It tries to sort video files without metadata.")
moderator.usageFormText = "sortphotos <params>"

let noExif = moderator.add(.option("n", "noexif", description: "Do not use exiftool. Just organize files to existing folders."))
let byCameraModel = moderator.add(.option("c", "camera", description: "Sort by camera model"))
let processM4V = moderator.add(.option("m", "m4v", description: "Sort M4V by name"))
let inputDir = moderator.add(Argument<String?>
    .optionWithValue("input", name: "Input directory", description: "Input directory for processing"))

do {
    try moderator.parse()
    guard let unwrappedInputDir = inputDir.value else {
        print(moderator.usagetext)
        exit(0)
    }

    Directory.current = try Directory(open: unwrappedInputDir)

    let inputFolder = try Folder(path: unwrappedInputDir)

    if !noExif.value {
        try inputFolder.exifTool(byCameraModel: byCameraModel.value, processM4V: processM4V.value)
    }
    try inputFolder.organizePhotos()
}
catch {
    if let printableError = error as? PrintableError { print(printableError.errorDescription) }
    else {
        print(error.localizedDescription)
    }

    exit(Int32(error._code))
}
