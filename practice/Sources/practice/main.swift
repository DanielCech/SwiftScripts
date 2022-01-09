import AppKit
import Files
import Foundation
import Moderator
import Toolkit
import SwiftShell


// MARK: - Main script

let moderator = Moderator(description: "Practice: perform an exercise with the logging of progress")
moderator.usageFormText = "practice <params>"

let activity = moderator.add(Argument<String?>
    .optionWithValue("activity", name: "Activity", description: "Path to the activity folder"))

let timer = moderator.add(.option("t", "timer", description: "Perform the timer"))

do {
    try moderator.parse()
    guard let unwrappedActivityDir = activity.value else {
        print(moderator.usagetext)
        exit(0)
    }

    print("⌚️ Processing")

    let activityFolder = try Folder(path: unwrappedActivityDir)

    guard let activity = try?  Activity(folder: activityFolder) else {
        print("Invalid activity")
        exit(1)
    }
    
    try? activity.start()
    
    print("✅ Done")
}
catch {
    if let printableError = error as? PrintableError { print(printableError.errorDescription) }
    else {
        print(error.localizedDescription)
    }

    exit(Int32(error._code))
}
