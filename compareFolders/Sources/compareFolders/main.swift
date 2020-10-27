import Files
import Foundation
import Moderator
import ScriptToolkit
import SwiftShell

struct ComparisonSetup {
    var ignoreMissing: Bool
    var ignoreMultiple: Bool
    var ignoreDifferences: Bool
    var compareDifferences: Bool
    var oneDirectional: Bool
}

func compare(source sourceFolder: Folder, target targetFolder: Folder, comparisonSetup: ComparisonSetup) throws {
    for sourceFile in sourceFolder.findFiles(regex: ".*") {
        let results = targetFolder.findFiles(name: sourceFile.name)
        if results.isEmpty {
            if !comparisonSetup.ignoreMissing {
                print("❌ source: \(sourceFile.name) not found in target folder")
            }
            continue
        }
        if results.count > 1 {
            if !comparisonSetup.ignoreMultiple {
                print("❓ source: \(sourceFile.name) there is more files with the same name:")
                for result in results {
                    print("   \(result.path)")
                }
            }
            continue
        }

        if comparisonSetup.ignoreDifferences { continue }

        let targetFile = results[0]

        let sourceFileURL = URL(fileURLWithPath: sourceFile.path)
        let sourceFileData = try Data(contentsOf: sourceFileURL)

        let targetFileURL = URL(fileURLWithPath: targetFile.path)
        let targetFileData = try Data(contentsOf: targetFileURL)

        if sourceFileData != targetFileData {
            print("❗️ source differs from target:")
            print("    source: \(sourceFile.path)")
            print("    target: \(targetFile.path)")

            if comparisonSetup.compareDifferences {
                let command = "\"/Applications/Araxis Merge.app/Contents/Utilities/compare\" \"" + sourceFile.path + "\" \"" + targetFile.path + "\""
                // print(command)
                shell(command)

                print("🟢 Press any key to continue...")
                _ = readLine()
            }
        }
    }
}

let moderator = Moderator(description: "Compare Folders")
moderator.usageFormText = "compareFolders <params>"

let firstDir = moderator.add(Argument<String?>.optionWithValue("first", name: "First directory", description: ""))

let secondDir = moderator.add(Argument<String?>.optionWithValue("second", name: "Second directory", description: ""))

let ignoreMissing = moderator.add(.option("ignoreMissing", description: "Ignore situations when file is on one side only"))

let ignoreMultiple = moderator.add(.option("ignoreMultiple", description: "Ignore situations when file has more counterparts"))

let ignoreDifferences = moderator.add(.option("ignoreDifferences", description: "Ignore file differences"))

let compareDifferences = moderator.add(.option("compareDifferences", description: "Use merge to compare different files"))

let oneDirectional = moderator.add(.option("oneDirectional", description: "Only one directional comparison"))

do {
    try moderator.parse()

    guard let unwrappedFirstDir = firstDir.value, let unwrappedSecondDir = secondDir.value else {
        print(moderator.usagetext)
        exit(0)
    }

    let comparisonSetup = ComparisonSetup(
        ignoreMissing: ignoreMissing.value,
        ignoreMultiple: ignoreMultiple.value,
        ignoreDifferences: ignoreDifferences.value,
        compareDifferences: compareDifferences.value,
        oneDirectional: oneDirectional.value
    )

    print("⌚️ Processing")

    let firstFolder = try Folder(path: unwrappedFirstDir)
    let secondFolder = try Folder(path: unwrappedSecondDir)

    print("1️⃣ First to second\n")

    try compare(source: firstFolder, target: secondFolder, comparisonSetup: comparisonSetup)

    if !comparisonSetup.oneDirectional {
        print("\n2️⃣ Second to first\n")

        try compare(source: secondFolder, target: firstFolder, comparisonSetup: comparisonSetup)
    }

    print("\n✅ Done")
}
catch {
    if let printableError = error as? PrintableError { print(printableError.errorDescription) }
    else {
        print(error.localizedDescription)
    }

    exit(Int32(error._code))
}
