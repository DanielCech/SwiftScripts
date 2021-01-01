import Files
import Foundation
import Moderator
import ScriptToolkit
import SwiftShell

/// Run shell command in bash
@discardableResult public func shell(_ command: String) -> String {
    let task = Process()
    let pipe = Pipe()

    task.standardOutput = pipe
    task.arguments = ["-c", command]
    task.launchPath = "/bin/bash"
    task.launch()

    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output = String(data: data, encoding: .utf8)!

    return output
}


func processFile(file: String, action: String) {
    let absoluteFileLine = main.currentdirectory.appendingPathComponent(path: file)
    
    var updatedAction: String
    updatedAction = action.replacingOccurrences(of: "@param@", with: file)
    updatedAction = updatedAction.replacingOccurrences(of: "@absolutepath@", with: absoluteFileLine)

    print(updatedAction)
    shell(updatedAction)
}


let moderator = Moderator(description: "Invoke shell command with argument from file or command line")
moderator.usageFormText = "invoke <params>"

let action = moderator.add(Argument<String?>
    .optionWithValue("action", name: "Shell action to run", description: "Use @param@, @absolutepath@ (using absolute path with argument)"))

let fileName = moderator.add(Argument<String?>
    .optionWithValue("file", name: "File with parameter values on each line", description: ""))

//let fileNames = moderator.add(Argument<String?>.optionWithValue(name: "files", description: "List of files from command line").repeat())

let fileNames = moderator.add(Argument<String?>.singleArgument(name: "multiple").repeat())
    
do {
    try moderator.parse()

    if fileName.value == nil && fileNames.value.isEmpty {
        print(moderator.usagetext)
        exit(0)
    }
    
    var fileAction: String
    if let unwrappedAction = action.value {
        fileAction = unwrappedAction
    }
    else {
        print("❔ Enter 'action': ", terminator: "")
        if let input = readLine() {
            fileAction = input
        }
        else {
            throw ScriptError.argumentError(message: "Invalid value for parameter action")
        }
    }

    print("⌚️ Processing")
    
    if let unwrappedFileName = fileName.value {
        let data = try String(contentsOfFile: unwrappedFileName, encoding: .utf8)
        let fileLines = data.components(separatedBy: .newlines)

        for fileLine in fileLines {
            processFile(file: fileLine, action: fileAction)
        }
    }
    else {
        for file in fileNames.value {
            processFile(file: file, action: fileAction)
        }
    }

    print("✅ Done")
}
catch {
    if let printableError = error as? PrintableError { print(printableError.errorDescription) }
    else {
        print(error.localizedDescription)
    }

    exit(Int32(error._code))
}
