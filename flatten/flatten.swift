import Foundation
import Files

let inputFolder = try Folder.current.subfolder(named: "Root")
let inputFolderPath = inputFolder.path
let index = inputFolderPath.index(inputFolderPath.startIndex, offsetBy: inputFolderPath.count)


let outputFolder = try Folder(path: "/Users/dan/Documents/Output")

try inputFolder.makeSubfolderSequence(recursive: true).forEach { folder in
    let folderPath = folder.path[index...]
    let folderPrefix = folderPath.replacingOccurrences(of: "/", with: " ")

    for file in folder.files {
        try file.rename(to: folderPrefix + " " + file.name, keepExtension: true)
        try file.move(to: outputFolder)
    }
}
