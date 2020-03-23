import Foundation
import Files
import Moderator
import ScriptToolkit
import SwiftShell
import FileSmith

private func changeName(_ text: String) -> String {
    var changedText = text
        .replacingOccurrences(of: "á", with: "a")
        .replacingOccurrences(of: "č", with: "c")
        .replacingOccurrences(of: "ď", with: "d")
        .replacingOccurrences(of: "é", with: "e")
        .replacingOccurrences(of: "ě", with: "e")
        .replacingOccurrences(of: "í", with: "i")
        .replacingOccurrences(of: "ó", with: "o")
        .replacingOccurrences(of: "ř", with: "r")
        .replacingOccurrences(of: "š", with: "s")
        .replacingOccurrences(of: "ť", with: "t")
        .replacingOccurrences(of: "ů", with: "u")
        .replacingOccurrences(of: "ú", with: "u")
        .replacingOccurrences(of: "ý", with: "y")
        .replacingOccurrences(of: "ž", with: "z")
    
    changedText = changedText
        .replacingOccurrences(of: "Á", with: "A")
        .replacingOccurrences(of: "Č", with: "C")
        .replacingOccurrences(of: "Ď", with: "D")
        .replacingOccurrences(of: "É", with: "E")
        .replacingOccurrences(of: "Ě", with: "E")
        .replacingOccurrences(of: "Í", with: "I")
        .replacingOccurrences(of: "Ó", with: "O")
        .replacingOccurrences(of: "Ř", with: "R")
        .replacingOccurrences(of: "Š", with: "S")
        .replacingOccurrences(of: "Ť", with: "T")
        .replacingOccurrences(of: "Ů", with: "U")
        .replacingOccurrences(of: "Ú", with: "U")
        .replacingOccurrences(of: "Ý", with: "Y")
        .replacingOccurrences(of: "Ž", with: "Z")
    
    return changedText
}

extension Folder {
    func removeDiacritics() throws {
        for folder in self.subfolders {
            let oldName = folder.nameExcludingExtension
            let newName = changeName(oldName)
            if oldName != newName {
                print("folder: \(oldName) -> \(newName)")
                try folder.rename(to: newName, keepExtension: true)
            }
        }
        
        for file in self.files {
            let oldName = file.nameExcludingExtension
            let newName = changeName(oldName)
            if oldName != newName {
                print("file: \(oldName) -> \(newName)")
                try file.rename(to: newName, keepExtension: true)
            }
        }
    }
}



let moderator = Moderator(description: "removes diactitics from filenames in current directory")

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
    try folder.removeDiacritics()
    print("✅ Done")
}
catch {
    print(error.localizedDescription)
    exit(Int32(error._code))
}
