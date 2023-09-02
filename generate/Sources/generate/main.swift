import Files
import Foundation
import Moderator
import ScriptToolkit
import SwiftShell

let moderator = Moderator(description: "Generate tool")
moderator.usageFormText = "generate <files or dirs>"

let filesAndDirs = moderator.add(Argument<String?>.singleArgument(name: "multiple").repeat())

do {
    try moderator.parse()
    guard filesAndDirs.value.count == 2 else {
        print(moderator.usageFormText)
        exit(0)
    }

    guard
        let sourcePath = filesAndDirs.value.first,
        let templatePath = filesAndDirs.value.last
    else {
        print(moderator.usageFormText)
        exit(0)
    }
    
    let pharoFile = "/Users/danielcech/ExternalCode.st"
    let command = "CodeTemplater generate: '\(sourcePath)' withTemplate: '\(templatePath)'."
    try command.write(toFile: pharoFile, atomically: true, encoding: .utf8)
    
}
catch {
    if let printableError = error as? PrintableError { print(printableError.errorDescription) }
    else {
        print(error.localizedDescription)
    }

    exit(Int32(error._code))
}
