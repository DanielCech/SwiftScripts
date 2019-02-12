import Foundation

import Foundation
import Files
import Moderator
import ScriptToolkit
import SwiftShell
import FileSmith

let moderator = Moderator(description: "Sorts folder of JPEG images to folders using EXIF metadata. It tries to sort video files without metadata.")
let noExif = moderator.add(.option("n","noexif", description: "Do not use exiftool. Just organize files to existing folders."))
let byCameraModel = moderator.add(.option("c","camera", description: "Sort by camera model"))
let processM4V = moderator.add(.option("m","m4v", description: "Sort M4V by name"))
let inputDir = moderator.add(Argument<String?>
    .optionWithValue("input", name: "Input directory", description: "Input directory for processing"))

do {
    try moderator.parse()
    if let inputFolder = inputDir.value {
        Directory.current = try Directory(open: inputFolder)
        if !noExif.value {
            try exifTool(inputDir: inputFolder, byCameraModel: byCameraModel.value, processM4V: processM4V.value)
        }
        try organizePhotos(inputDir: inputFolder)
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
