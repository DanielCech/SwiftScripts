import Foundation

import Files
import FileSmith
import Foundation
import Moderator
import ScriptToolkit
import SwiftShell

let timer = Timer()
let exercises = Exercises()
let scheduler = Scheduler()
var interest: String

let moderator = Moderator(description: "Structured timer for practice")
moderator.usageFormText = "practice-timer <params>"

let interestArgument = moderator.add(Argument<String?>
    .optionWithValue("interest", name: "The area of interest", description: "It can be bass/guitar/..."))

let planArgument = moderator.add(Argument<String?>
    .optionWithValue("plan", name: "The exercise plan", description: "It can be 20min/40min/60min..."))

print("⏰ Timer 0.1.0\n")

do {
    try moderator.parse()
    
    guard
        let unwrappedInterest = interestArgument.value
    else {
        print(moderator.usagetext)
        exit(0)
    }
    
    interest = unwrappedInterest.capitalized
    
    try exercises.openEntries()
    
    try exercises.saveEntries()
    
//    // Prepare plan
//    try scheduler.preparePlan()
//    scheduler.presentPlan()
    
    while true {
        print("▷ ", terminator: "")
        let input = readLine()
        
        switch input {
        case "init", "i":
            try exercises.initialize()
            break
            
        case "start", "s":
            break
            
        case "generate", "g":
            try scheduler.preparePlan()
            scheduler.presentPlan()
            
        case "log", "l":
            break
            
        case "done", "d":
            break
            
        case "exit", "e":
            print("✅ Done")
            exit(0)
            
        default:
            print("⚠️ Unknown command")
        }
        
        print("")
    }
    
    
}
catch {
    if let printableError = error as? PrintableError { print(printableError.errorDescription) }
    else {
        print(error.localizedDescription)
    }

    exit(Int32(error._code))
}
