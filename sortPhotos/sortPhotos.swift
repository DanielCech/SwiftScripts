import Foundation

import Foundation
import Files
import Moderator
import ScriptToolkit
import SwiftShell
import FileSmith

public func exifTool(inputDir: String) throws {
    let inputFolder = try Folder(path: inputDir)

    for dir in inputFolder.subfolders {
        print("dir: \(dir.name)")
        try runAndPrint("/usr/local/bin/exiftool","-Directory<DateTimeOriginal", "-d", "%Y-%m-%d \(dir.name)", dir.path)
    }

    for file in inputFolder.files {
        print("file: \(file.name)")
        try runAndPrint("/usr/local/bin/exiftool" ,"-Directory<DateTimeOriginal", "-d", "%Y-%m-%d", file.path)
    }

    var folderRecords = [(Folder, [Int])]()

    let sortedSubfolders = inputFolder.subfolders.sorted { $0.name < $1.name }

    for dir in sortedSubfolders {
        let indexes = dir.files
            .map { $0.nameExcludingExtension.replacingOccurrences(of: "IMG_", with: "") }
            .compactMap { Int($0) }
            .sorted()
        folderRecords.append((dir, indexes))
    }

    for file in inputFolder.files {
        let numberString = file.nameExcludingExtension.replacingOccurrences(of: "IMG_", with: "")
        var lastMaximum: Int?
        if let number = Int(numberString) {

            for folderRecord in folderRecords {
                if let firstIndex = folderRecord.1.first, let lastIndex = folderRecord.1.last, number >= firstIndex, number <= lastIndex {
                    try file.move(to: folderRecord.0)
                    print("Success")
                    break
                }

                if let unwrappedLastMaximum = lastMaximum, let firstIndex = folderRecord.1.first, unwrappedLastMaximum <= number, firstIndex >= number {
                    try file.move(to: folderRecord.0)
                    print("Success")
                    break
                }

                lastMaximum = folderRecord.1.last
            }
        }
    }

}

let moderator = Moderator(description: "Sorts folder of JPEG images to folders using EXIF metadata. It tries to sort video files without metadata.")

let inputDir = moderator.add(Argument<String?>
    .optionWithValue("input", name: "Input directory", description: "Input directory for processing"))

do {
    try moderator.parse(["--input", "/Users/dan/Documents/Test"])
    if let inputFolder = inputDir.value {
        Directory.current = try Directory(open: inputFolder)
        try exifTool(inputDir: inputFolder)
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
    print("sortPhotos failed: \(error.localizedDescription)")
    exit(1)
}
