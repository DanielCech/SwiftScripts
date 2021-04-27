import Foundation

import Files
import FileSmith
import Foundation
import Moderator
import ScriptToolkit
import SwiftShell

func openInterest(_ interest: String) throws -> Entry {
    let exercisesFile = try Folder.current.file(named: "\(interest.capitalized)Exercises.json")

    let jsonString = try exercisesFile.readAsString(encodedAs: .utf8)
    let jsonData = Data(jsonString.utf8)

    do {
        
        let entry = try JSONDecoder().decode(Entry.self, from: jsonData)
        // make sure this JSON is in the format we expect
//        guard let entry = try JSONSerialization.jsonObject(with: jsonData, options: []) as? Entry else {
//            throw ScriptError.generalError(message: "Unable to read exercises json")
//        }
        
        return entry
    }
}



let moderator = Moderator(description: "Structured timer for practice")
moderator.usageFormText = "practice-timer <params>"

let interest = moderator.add(Argument<String?>
    .optionWithValue("interest", name: "The area of interest", description: "It can be bass/guitar/..."))

let set = moderator.add(Argument<String?>
    .optionWithValue("set", name: "The execrise set", description: "Enter the name of set"))

do {
    try moderator.parse()
    guard let unwrappedInterest = interest.value else {
        print(moderator.usagetext)
        exit(0)
    }
    
    let entry = try openInterest(unwrappedInterest)
    print(entry)
}
catch {
    if let printableError = error as? PrintableError { print(printableError.errorDescription) }
    else {
        print(error.localizedDescription)
    }

    exit(Int32(error._code))
}
