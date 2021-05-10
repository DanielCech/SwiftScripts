//
//  Entry.swift
//  practiceTimer
//
//  Created by Daniel Cech on 27/04/2021.
//

import Foundation


/// Structure for practice exercise
struct Entry: Codable {
    /// Identifier
    var id: String?
    
    /// Subitems list
    var items: [Entry]?
    
    /// Name of exercise
    var name: String?
    
    /// PDF file to open
    var pdf: String?
    
    /// Open PDF on page
    var pdfPage: String?
    
    /// Open media file
    var media: String?
    
    /// Total time spent with this exercise
    var totalTime: TimeInterval?
    
    /// Last time when practised
    var lastPracticeDate: Date?
    
    /// How good I am - 0-100%
    var rating: Int?
    
    /// Expected duration of this exercise
    var defaultDuration: TimeInterval?
    
    /// How important is this exercise
    var importancy: Int?
}
