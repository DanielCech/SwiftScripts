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

let moderator = Moderator(description: "PharoCall tool")
moderator.usageFormText = "pharoCall <command> <sourceSelection> <targetSelection> <sourcePath> <targetPath>"

let arguments = moderator.add(Argument<String?>.singleArgument(name: "multiple").repeat())

do {
    try moderator.parse()
    guard arguments.value.count == 5 else {
        print(moderator.usageFormText)
        exit(0)
    }

    guard
        let command = arguments.value[safe: 0],
        let sourceSelection = arguments.value[safe: 1],
        let targetSelection = arguments.value[safe: 2],
        let sourcePath = arguments.value[safe: 3],
        let targetPath = arguments.value[safe: 4]
    else {
        print(moderator.usageFormText)
        exit(0)
    }
    
    let pharoFile = "/Users/danielcech/pharoExternalCode.st"
    let commandText = "ExternalCode runCommand: '\(command)' sourceSelection: '\(sourceSelection)' targetSelection: '\(targetSelection)' sourcePath: '\(sourcePath)' targetPath: '\(targetPath)'."
    try commandText.write(toFile: pharoFile, atomically: true, encoding: .utf8)
    
}
catch {
    if let printableError = error as? PrintableError { print(printableError.errorDescription) }
    else {
        print(error.localizedDescription)
    }

    exit(Int32(error._code))
}
