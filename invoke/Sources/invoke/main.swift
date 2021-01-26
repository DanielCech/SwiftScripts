import Files
import Foundation
import Moderator
import ScriptToolkit
import SwiftShell

/// Run shell command in bash
@discardableResult public func shell(_ command: String) -> String {
    let task = Process()
//    let outputPipe = Pipe()
//    let errorPipe = Pipe()

//    task.standardOutput = outputPipe
//    task.standardError = errorPipe

    // task.arguments = ["-c"] + (command.split(separator: " ").map { String($0) })
    
    // Fungujici
    //task.arguments = ["-c", "/usr/local/bin/ffmpeg -i \"/Users/dan/Documents/Temp/Process/Aeroplane.mp3\" \"/Users/dan/Documents/Temp/Process/Aeroplane.wav\""]
    
    task.arguments = ["-c", command]
    
    print("/usr/local/bin/ffmpeg -i \"/Users/dan/Documents/Temp/Process/Aeroplane.mp3\" \"/Users/dan/Documents/Temp/Process/Aeroplane.wav\"")
    print(command)
    print(command == "/usr/local/bin/ffmpeg -i \"/Users/dan/Documents/Temp/Process/Aeroplane.mp3\" \"/Users/dan/Documents/Temp/Process/Aeroplane.wav\"")
    
    task.launchPath = "/bin/bash"
    try? task.run()
    
//    print("Continue?")
//    readLine()

//    let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
//    let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
//
//    let output = String(decoding: outputData, as: UTF8.self)
//    let error = String(decoding: errorData, as: UTF8.self)
//
//    print("Output:\n \(output)")
//
//    print("ErrorOutput:\n \(error)")

    return ""
}


func process(path: String, action: String) {
    let absolutePath: String
    if path.isAbsolutePath {
        absolutePath = path
    }
    else {
        absolutePath = main.currentdirectory.appendingPathComponent(path: path)
    }
    
    let absolutePathNoExt = absolutePath.deletingPathExtension
    let localPath = path.lastPathComponent
    let localPathNoExt = localPath.deletingPathExtension
    let ext = path.pathExtension
    
    var updatedAction: String
    updatedAction = action.replacingOccurrences(of: "@path@", with: path)
    updatedAction = updatedAction.replacingOccurrences(of: "@absolutePath@", with: absolutePath)
    updatedAction = updatedAction.replacingOccurrences(of: "@absolutePathNoExt@", with: absolutePathNoExt)
    updatedAction = updatedAction.replacingOccurrences(of: "@localPath@", with: localPath)
    updatedAction = updatedAction.replacingOccurrences(of: "@localPathNoExt@", with: localPathNoExt)
    updatedAction = updatedAction.replacingOccurrences(of: "@ext@", with: ext)

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
            process(path: fileLine, action: fileAction)
        }
    }
    else {
        for file in fileNames.value {
            process(path: file, action: fileAction)
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
