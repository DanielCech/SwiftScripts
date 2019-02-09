import Foundation
import Files
import SwiftShell
import Moderator
import ScriptToolkit

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
