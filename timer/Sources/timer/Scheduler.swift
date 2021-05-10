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
    
    var currentPlan: Plan = []
    var currentTaskIndex: Int = 0
        
    func preparePlan() throws {
        let possiblePlans = generatePlans()
        if let bestPlan = sortPlans(possiblePlans).first {
            currentPlan = bestPlan
        }
        else {
            throw ScriptError.generalError(message: "No generated plan")
        }
    }
    
    func generatePlans() -> [Plan] {
        var plans = [Plan]()
        
        for _ in 0 ..< FileConstants.planCount {
            var plan = Plan()
            
//            plan = addWarmUpExercices(to: plan)
//            plan = addRepeatedExercises(to: plan)
//            plan = addTechnicalExercises(to: plan)
//            plan = addSongExercises(to: plan)
            
            plans.append(plan)
        }
        
        return plans
    }
    
    func sortPlans(_ plans: [Plan]) -> [Plan] {
        return []
    }
    
    func presentPlan() {
        for (index, entry) in currentPlan.enumerated() {
            print("\(index) \(entry.name ?? "")")
        }
    }
    
}

extension Scheduler {
    func addWarmUpExercices(to plan: Plan) {
        
    }
    
    func addRepeatedExercises(to plan: Plan) {
        
    }
    
    func addTechnicalExercises(to plan: Plan) {
        
    }
    
    func addSongExercises(to plan: Plan) {
        
    }
}

private enum FileConstants {
    static let planCount = 3
    
}
