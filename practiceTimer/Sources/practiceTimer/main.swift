import Foundation

import Files
import FileSmith
import Foundation
import Moderator
import ScriptToolkit
import SwiftShell

let timer = Timer()
let scheduler = Scheduler()

let moderator = Moderator(description: "Structured timer for practice")
moderator.usageFormText = "practice-timer <params>"

let interest = moderator.add(Argument<String?>
    .optionWithValue("interest", name: "The area of interest", description: "It can be bass/guitar/..."))

let planTypeString = moderator.add(Argument<String?>
    .optionWithValue("plan", name: "The name of the plan", description: "The combination of exercises."))

do {
    try moderator.parse()
    
    guard
        let unwrappedInterest = interest.value,
        let unwrappedPlanTypeString = planTypeString.value
    else {
        print(moderator.usagetext)
        exit(0)
    }
    
    try scheduler.openInterest(unwrappedInterest)
    let plan = try scheduler.preparePlan(unwrappedPlanTypeString)
    
    timer.play(plan)
}
catch {
    if let printableError = error as? PrintableError { print(printableError.errorDescription) }
    else {
        print(error.localizedDescription)
    }

    exit(Int32(error._code))
}
