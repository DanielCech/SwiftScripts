//
//  StringExtension.swift
//  CodeTemplates
//
//  Created by Daniel Cech on 13/06/2020.
//

import Foundation
import ScriptToolkit

public extension String {
    //    /// Conversion to PascalCase
    func capitalized() -> String {
        let first = String(prefix(1)).uppercased()
        let other = String(dropFirst())
        return first + other
    }
    
    /// Conversion to PascalCase
    mutating func capitalize() {
        self = capitalized()
    }
    
    /// Conversion to camelCase
    func decapitalized() -> String {
        let first = String(prefix(1)).lowercased()
        let other = String(dropFirst())
        return first + other
    }
    
    /// Conversion to camelCase
    mutating func decapitalize() {
        self = decapitalized()
    }
    
    func replace(value: Any?, arguments: [Any?]) throws -> Any? {
        guard arguments.count <= 2 else {
            throw ScriptError.generalError(message: "'indent' filter can take at most 2 arguments")
        }
        
        guard let unwrappedValue = value as? String else {
            throw ScriptError.generalError(message: """
            value must be string
            """)
        }
        
        guard let what = arguments[0] as? String else {
            throw ScriptError.generalError(message: """
            first argument must be string
            """)
        }
        
        guard let with = arguments[1] as? String else {
            throw ScriptError.generalError(message: """
            second argument must be string
            """)
        }
        
        return unwrappedValue.replacingOccurrences(of: what, with: with)
    }
    
}

extension String {
    /// Returns the path without trailing slash
    func withoutSlash() -> String {
        if last == "/" {
            return String(prefix(count - 1))
        }
        return self
    }
}

// MARK: - Regular expressions

extension String {
    /// Regular expression matches
    func regExpMatches(lineRegExp: String) throws -> [NSTextCheckingResult] {
        let nsrange = NSRange(startIndex..<endIndex, in: self)
        let regex = try NSRegularExpression(pattern: lineRegExp, options: [.anchorsMatchLines])
        let matches = regex.matches(in: self, options: [], range: nsrange)
        return matches
    }
    
    /// Regular expression matches
    func regExpStringMatches(lineRegExp: String) throws -> [String] {
        let matches = try regExpMatches(lineRegExp: lineRegExp)
        
        let ranges = matches.compactMap { Range($0.range, in: self) }
        let substrings = ranges.map { self[$0] }
        let strings = substrings.map { String($0) }
        return strings
    }
    
    /// Regular expression substitutions
    func stringByReplacingMatches(pattern: String, withTemplate template: String) throws -> String {
        let regex = try NSRegularExpression(pattern: pattern)
        return regex.stringByReplacingMatches(
            in: self,
            options: .reportCompletion,
            range: NSRange(location: 0, length: count),
            withTemplate: template
        )
    }
}

