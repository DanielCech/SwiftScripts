//
//  Entry.swift
//  practiceTimer
//
//  Created by Daniel Cech on 27/04/2021.
//

import Foundation

enum EntryType: String, Codable {
    case folder
    case exercise
}


/// Structure for practice exercise
struct Entry: Codable {
    // Identifier
    var id: String?
    
    // Type - exercises/folder
    var type: EntryType
    
    // 
    var items: [Entry]?
    
    // Name of exercise
    var name: String?
    
    // Total time spent with this exercise
    var totalTime: TimeInterval?
    
    // Last time when practised
    var lastPracticeDate: Date?
    
    // How good I am - 0-100%
    var rating: Int?
    
    // Expected duration of this exercise
    var defaultDuration: TimeInterval?
    
    // How important is this exercise
    var importancy: Int?
}
