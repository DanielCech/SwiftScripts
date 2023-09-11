import Files
import Foundation
import Moderator
import ScriptToolkit
import SwiftShell

extension Collection {
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

func collectionFilePath() throws -> String {
    let directories : [String] = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.userDirectory, FileManager.SearchPathDomainMask.allDomainsMask, true)
    
    guard let directory = directories[safe: 0] else {
        throw ScriptError.folderNotFound(message: "home folder not found")
    }
    
    return directory.appendingFormat("/danielcech/pharoCollection.txt")
}


func divideFileNames(text: String) -> [String] {
    text.split(separator: " ").map { String($0) }
}


let moderator = Moderator(description: "pharoCollect tool - manages a collection of paths for use in Pharo ")
moderator.usageFormText = "pharoCollect <command> <paths>"

let addCommand = moderator.add(.option("a", "add", description: "Adds paths to the collection"))
let clearCommand = moderator.add(.option("c", "clear", description: "Clears the list of paths"))

let path = moderator.add(Argument<String?>.singleArgument(name: "multiple"))

do {
    try moderator.parse()
    
    let filePath = try collectionFilePath()
    let fileManager = FileManager.default
    
    if clearCommand.value {
        if fileManager.fileExists(atPath: filePath) {
            try fileManager.removeItem(atPath: filePath)
        }
    } else {
        guard let text = path.value else {
            throw ScriptError.argumentError(message: "Invalid path")
        }
        let data = (text + "\n").data(using: .utf8) ?? Data()
        
        if fileManager.fileExists(atPath: filePath) {
            if let fileHandle = FileHandle(forWritingAtPath: filePath) {
                fileHandle.seekToEndOfFile()
                fileHandle.write(data)
                fileHandle.closeFile()
            }
        } else {
            let url = URL(fileURLWithPath: filePath)
            try? data.write(to: url, options: .atomicWrite)
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
