//
//  Scheduler.swift
//  practiceTimer
//
//  Created by Daniel Cech on 27/04/2021.
//

import Foundation
import Files
import ScriptToolkit

class Scheduler {
    lazy var mainEntry: Entry = { Entry(type: .folder) }()
    
    func openInterest(_ interest: String) throws {
        let exercisesFile = try Folder.current.file(named: "\(interest.capitalized)Exercises.json")

        let jsonString = try exercisesFile.readAsString(encodedAs: .utf8)
        let jsonData = Data(jsonString.utf8)

        do {
            let entry = try JSONDecoder().decode(Entry.self, from: jsonData)
            mainEntry = entry
        }
    }
    
    func preparePlan(_ planString: String) throws -> Plan {
        guard let plan = PlanType(rawValue: planString) else {
            throw ScriptError.argumentError(message: "plan value '\(planString)' is not supported")
        }
        
        return []
    }
}
