import Foundation
import Files
import Moderator
import ScriptToolkit
import SwiftShell

@discardableResult func shell(_ command: String) -> String {
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

let moderator = Moderator(description: "Invoke shell command with argument from file or command line")
moderator.usageFormText = "invoke <params>"

let action = moderator.add(Argument<String?>
    .optionWithValue("action", name: "Shell action to run", description: "Use @param@, @absolutepath@ (using absolute path with argument)"))

let fileName = moderator.add(Argument<String?>
    .optionWithValue("file", name: "File with parameter values on each line", description: ""))

do {
    try moderator.parse()

    guard let unwrappedFileName = fileName.value, let unwrappedAction = action.value else {
        print(moderator.usagetext)
        exit(0)
    }
    
    print("⌚️ Processing")
    
    let data = try String(contentsOfFile: unwrappedFileName, encoding: .utf8)
    let fileLines = data.components(separatedBy: .newlines)
    var updatedAction: String
    
    for fileLine in fileLines {
        let absoluteFileLine = main.currentdirectory.appendingPathComponent(path: fileLine)
        
        updatedAction = unwrappedAction.replacingOccurrences(of: "@param@", with: fileLine)
        updatedAction = updatedAction.replacingOccurrences(of: "@absolutepath@", with: absoluteFileLine)
        
        print(updatedAction)
        shell(updatedAction)
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
