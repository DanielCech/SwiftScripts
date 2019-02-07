import Foundation
import Files
import SwiftShell
import Moderator

extension File {
    func createDuplicate(withName newName: String, keepExtension: Bool = true) throws {
        guard let parent = parent else {
            throw OperationError.renameFailed(self)
        }

        var newName = newName

        if keepExtension {
            if let `extension` = `extension` {
                let extensionString = ".\(`extension`)"

                if !newName.hasSuffix(extensionString) {
                    newName += extensionString
                }
            }
        }

        let newPath = parent.path + newName

        do {
            try FileManager.default.copyItem(atPath: path, toPath: newPath)
        } catch {
            throw OperationError.renameFailed(self)
        }
    }
}

let dateFormatter = DateFormatter()
dateFormatter.dateFormat = "YYYY-MM-dd"

func tag(_ item: String, copy: Bool) throws {
    let suffix = dateFormatter.string(from: Date())
    for letter in "abcdefghijklmnopqrstuvwxyz" {
        let file = try File(path: item)
        let newPath = (file.parent?.path ?? "./")
        let newName = file.nameExcludingExtension + "(\(suffix + String(letter)))" + "." + (file.extension ?? "")

        if !FileManager.default.fileExists(atPath: newPath + newName) {
            if copy {
                try file.createDuplicate(withName: newName)
            }
            else {
                try file.rename(to: newName)
            }
            return
        }
    }
}


let moderator = Moderator(description: "Tag file with timestamp (YYYY-MM-DDc)")
let onCopy = moderator.add(.option("c","copy", description: "Tags copy of the file"))
let filesAndDirs = moderator.add(Argument<String?>.singleArgument(name: "multiple").repeat())

do {
    try moderator.parse()
    if filesAndDirs.value.isEmpty {
        print(moderator.usagetext)
    }
    else {
        for item in filesAndDirs.value {
            try tag(item, copy: onCopy.value)
        }
    }


}
catch let error as ArgumentError {
    print(error.errormessage)
    exit(Int32(error._code))
}
catch {
    print("tagFile failed: \(error.localizedDescription)")
    exit(1)
}
