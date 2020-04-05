import Foundation
import Files
import Moderator
import ScriptToolkit
import SwiftShell


let moderator = Moderator(description: "CropPDF - Crop pdf insets for practising on iPad")

let inputDirArgument = Argument<String?>
    .optionWithValue("input", name: "Input directory", description: "Script works only locally and need to set current path")
let inputDir = moderator.add(inputDirArgument)

let outputDirArgument = Argument<String?>
    .optionWithValue("output", name: "Output directory", description: "Output directory for generated pdfs")
    .default(main.currentdirectory.appending("output"))
let outputDir = moderator.add(outputDirArgument)

let files = moderator.add(Argument<String?>.singleArgument(name: "multiple").repeat())


do {
    try moderator.parse()

    guard !files.value.isEmpty || inputDir.value == nil else {
        print(moderator.usagetext)
        exit(0)
    }

    main.currentdirectory = inputDir.value!

    print("⌚️ Processing")

    try Folder.root.createSubfolderIfNeeded(at: outputDir.value)
    
    let outputFolder = try Folder(path: outputDir.value)

    for item in files.value {
        let file = try File(path: item)
        let newName = outputFolder.path.appending(file.name)
        try file.cropPDF(newName: newName, insets: NSEdgeInsets(top: -4, left: -2, bottom: -4, right: -2))
    }

    print("✅ Done")
}
catch {
    print(error.localizedDescription)

    exit(Int32(error._code))
}
