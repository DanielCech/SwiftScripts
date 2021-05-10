//
//  Exercises.swift
//  timer
//
//  Created by Daniel Cech on 09/05/2021.
//

import Foundation
import Files
import ScriptToolkit

class Exercises {
    lazy var mainEntry: Entry = { Entry(name: "Root", isFinal: false) }()
    
    // MARK: - Init entries
    
    func initialize() throws {
        let interestFolder = try Folder(path: Constants.mainPath).subfolder(named: interest)
        
        try initEntries(folder: interestFolder)
    }
    
    func initEntries(folder: Folder) throws {
        let exerciseFilePath = folder.path.appendingPathComponent(path: "exercise.json")
        
        for subfolder in folder.subfolders {
            if subfolder.name == "Ignore" {
                continue
            }
            
            try initEntries(folder: subfolder)
        }
        
        let entry = Entry(
            name: folder.name,
            items: nil,
            isFinal: false,
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
        
        let exerciseFileURL = URL(fileURLWithPath: exerciseFilePath)
        try jsonString.write(to: exerciseFileURL, atomically: true, encoding: .utf8)
    }
    
    // MARK: - Open entries
    
    func openEntries() throws {
        let interestFolder = try Folder(path: Constants.mainPath).subfolder(named: interest)
        
        mainEntry = try openEntries(folder: interestFolder)
    }
    
    @discardableResult func openEntries(folder: Folder) throws -> Entry {
        let exerciseFilePath = folder.path.appendingPathComponent(path: "exercise.json")
        
        guard FileManager.default.locationExists(path: exerciseFilePath, kind: .file) else {
            throw ScriptError.fileNotFound(message: exerciseFilePath)
        }
        
        let jsonData = try Data(contentsOf: URL(fileURLWithPath: exerciseFilePath))
        var entry = try JSONDecoder().decode(Entry.self, from: jsonData)
        
        // If items array is explicitly empty - do not load the subfolders
        if let unwrappedItems = entry.items, unwrappedItems.isEmpty {
            return entry
        }
        
        var entries = [Entry]()
        
        if !entry.isFinal {
            for subfolder in folder.subfolders {
                if subfolder.name == "Ignore" {
                    continue
                }
                
                entries.append(try openEntries(folder: subfolder))
            }
            
            entry.items = entries
        }
    
        return entry
    }
    
    // MARK: - Save entries
    
    func saveEntries() throws {
        let interestFolder = try Folder(path: Constants.mainPath).subfolder(named: interest)

        try saveEntries(folder: interestFolder, entry: mainEntry)
    }
    
    func saveEntries(folder: Folder, entry: Entry) throws {
        let exerciseFilePath = folder.path.appendingPathComponent(path: "exercise.json")
        
        if let unwrappedItems = entry.items {
            for item in unwrappedItems {
                if item.name == "Ignore" {
                    continue
                }
                
                try saveEntries(folder: folder.subfolder(named: item.name), entry: item)
            }
        }
        
        var mutableEntry = entry
        if !mutableEntry.isFinal {
            mutableEntry.items = nil
        }
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        let jsonData = try! encoder.encode(mutableEntry)
        let jsonString = String(data: jsonData, encoding: .utf8)!
        
        let exerciseFileURL = URL(fileURLWithPath: exerciseFilePath)
        try jsonString.write(to: exerciseFileURL, atomically: true, encoding: .utf8)
    }
}

extension Exercises {
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
