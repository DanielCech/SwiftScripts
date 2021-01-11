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
    task.arguments = ["-c", "\"\(command)\""]
    task.launchPath = "/bin/bash"
    task.launch()

    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output = String(data: data, encoding: .utf8)!

    return output
}


func processFile(file: String, action: String) {
    let absoluteFile: String
    if file.isAbsolutePath {
        absoluteFile = file
    }
    else {
        absoluteFile = main.currentdirectory.appendingPathComponent(path: file)
    }
    
    let absoluteFileNoExt = absoluteFile.deletingPathExtension
    let localFile = file.lastPathComponent
    let localFileNoExt = localFile.deletingPathExtension
    let ext = file.pathExtension
    
    var updatedAction: String
    updatedAction = action.replacingOccurrences(of: "@file@", with: "\"\(file)\"")
    updatedAction = updatedAction.replacingOccurrences(of: "@absoluteFile@", with: "\\\"\(absoluteFile)\\\"")
    updatedAction = updatedAction.replacingOccurrences(of: "@absoluteFileNoExt@", with: "\\\"\(absoluteFileNoExt)\\\"")
    updatedAction = updatedAction.replacingOccurrences(of: "@localFile@", with: "\\\"\(localFile)\\\"")
    updatedAction = updatedAction.replacingOccurrences(of: "@localFileNoExt@", with: "\\\"\(localFileNoExt)\\\"")
    updatedAction = updatedAction.replacingOccurrences(of: "@ext@", with: "\\\"\(ext)\\\"")

    print(updatedAction)
    shell(updatedAction)
}


let moderator = Moderator(description: "Invoke shell command with argument from file or command line")
moderator.usageFormText = "invoke <params>"

let action = moderator.add(Argument<String?>
    .optionWithValue("action", name: "Shell action to run", description: "Use @file@ - original file,\n      @absoluteFile@ - file with absolute path\n      @absoluteFileNoExt@ - file with absolute path without extension\n      @localFile@ - file without path\n      @localFileNoExt@ - file without path and extension\n      @ext@ - the extension of file"))

let fileName = moderator.add(Argument<String?>
    .optionWithValue("file", name: "File with parameter values on each line;\n      You can specify files as normal parameters", description: ""))

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
