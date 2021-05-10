//
//  Exercises.swift
//  timer
//
//  Created by Daniel Cech on 09/05/2021.
//

import Foundation
import Files

class Exercises {
    lazy var mainEntry: Entry = { Entry() }()
    
    func initialize() throws {
        let interestFolder = try Folder(path: Constants.mainPath).subfolder(named: interest)
        
        try initEntries(folder: interestFolder)
    }
    
    func initEntries(folder: Folder) throws {
        let exerciseFilePath = folder.path.appendingPathComponent(path: "exercise.json")
        
        for subfolder in folder.subfolders {
            try initEntries(folder: subfolder)
        }
        
        let entry = Entry(
            id: folder.path(relativeTo: Constants.mainFolder),
            items: nil,
            name: folder.name,
            totalTime: nil,
            lastPracticeDate: nil,
            rating: nil,
            defaultDuration: nil,
            importancy: 50
        )
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        let jsonData = try! encoder.encode(entry)
        let jsonString = String(data: jsonData, encoding: .utf8)!
        print(jsonString)
        
        let exerciseFileURL = URL(fileURLWithPath: exerciseFilePath)
        try jsonString.write(to: exerciseFileURL, atomically: true, encoding: .utf8)
    }
    
    
    func openEntries() throws {
        let interestFolder = try Folder(path: Constants.mainPath).subfolder(named: interest)
        
        mainEntry = try openEntries(folder: interestFolder)
    }
    
    @discardableResult func openEntries(folder: Folder) throws -> Entry {
        let exerciseFilePath = folder.path.appendingPathComponent(path: "exercise.json")
        
        let jsonData = try Data(contentsOf: URL(fileURLWithPath: exerciseFilePath))
        var entry = try JSONDecoder().decode(Entry.self, from: jsonData)
        
        // If items array is explicitly empty - do not load the subfolders
        if let unwrappedItems = entry.items, unwrappedItems.isEmpty {
            return entry
        }
        
        var entries = [Entry]()
        
        for subfolder in folder.subfolders {
            entries.append(try openEntries(folder: subfolder))
        }
        
        entry.items = entries
        
        return entry
    }
    
    func openPDF(file: String, page: Int?) {
        let scriptSource: String
        
        if let unwrappedPage = page {
            scriptSource =
                """
                tell application "Adobe Acrobat Reader DC"
                    open POSIX file "{{file}}" options "page={{page}}"
                end tell
                """
                .replacingOccurrences(of: "{{file}}", with: file)
                .replacingOccurrences(of: "{{page}}", with: String(unwrappedPage))
        }
        else {
            scriptSource =
                """
                tell application "Adobe Acrobat Reader DC"
                    open POSIX file "{{file}}"
                end tell
                """
                .replacingOccurrences(of: "{{file}}", with: file)
        }
        
        let script = NSAppleScript(source: scriptSource)
        script?.executeAndReturnError(nil)
    }
    
    func openMedia(file: String) {
        let scriptSource =
            """
            tell application "VLC"
                OpenURL "file://{{file}}"
                delay 5
                play
            end tell
            """
            .replacingOccurrences(of: "{{file}}", with: file)
        
        let script = NSAppleScript(source: scriptSource)
        script?.executeAndReturnError(nil)
    }
}
