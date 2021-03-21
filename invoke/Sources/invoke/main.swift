import Files
import Foundation
import Moderator
import ScriptToolkit
import SwiftShell
import Stencil

/// Stencil environment for templates
let environment = stencilEnvironment()
var itemIndex = 1

/// Run shell command in bash
public func runShell(_ command: String) {
    let task = Process()
    
    task.arguments = ["-c", command]
    task.launchPath = "/bin/bash"
    
    try? task.run()
}


func process(path: String, action: String) throws -> String {
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
    
    var context = [String: Any]()
    context["path"] = path
    context["absolutePath"] = absolutePath
    context["absolutePathNoExt"] = absolutePathNoExt
    context["localPath"] = localPath
    context["localPathNoExt"] = localPathNoExt
    context["ext"] = ext
    context["index"] = itemIndex
    
    itemIndex += 1
    
    var updatedAction: String
    do {
        updatedAction = try environment.renderTemplate(string: action, context: context)
    }
    catch {
        throw ScriptError.generalError(message: "Error in stencil template")
    }
    
    return "echo \"\(path):\"\n" + updatedAction + "\n\n"
}

func saveAndRun(_ script: String) throws {
    let homeFolder = FileManager.default.homeDirectoryForCurrentUser
    let scriptFile = homeFolder.appendingPathComponent("invoke.sh")
    
    try script.write(to: scriptFile, atomically: true, encoding: .utf8)
    
    if perform.value {
        runShell(scriptFile.path)
    }
}


let moderator = Moderator(description: "Invoke shell command with argument from file or command line")
moderator.usageFormText = "invoke <params>"

let action = moderator.add(Argument<String?>
    .optionWithValue("action", name: "Shell action to run with support of Stencil language", description:
                     """

                         Variables:
                            {{path}} - for original path,
                            {{absolutePath}} - absolute location in file system
                            {{absolutePathNoExt}} absolute path without extension
                            {{localPath}} - file/folder without parent folder
                            {{localPathNoExt}} - file/folder without parent folder and extension
                            {{ext}} - the extension of file
                            {{index}} - index of processed file

                         Filters:
                            capitalized
                            decapitalized
                            uppercased
                            lowercased
                            replace:what, with
                            removeDiacritics

                     """))

let perform = moderator.add(.option("perform", description: "Perform the call. Without this parameter you can just test the result. The result script is in ~/invoke.sh."))

let fileName = moderator.add(Argument<String?>
    .optionWithValue("file", name: "File with parameter values on each line;\n      You can specify files as normal parameters", description: ""))

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
    
    var script = "#! /bin/sh\n\n"
    
    if let unwrappedFileName = fileName.value {
        let data = try String(contentsOfFile: unwrappedFileName, encoding: .utf8)
        let fileLines = data.components(separatedBy: .newlines)

        for fileLine in fileLines {
            script += try process(path: fileLine, action: fileAction)
        }
    }
    else {
        for file in fileNames.value {
            script += try process(path: file, action: fileAction)
        }
    }

    print(script)
    try saveAndRun(script)
    
    print("✅ Done")
}
catch {
    if let printableError = error as? PrintableError { print(printableError.errorDescription) }
    else {
        print(error.localizedDescription)
    }

    exit(Int32(error._code))
}
