//
//  Environment.swift
//  invoke
//
//  Created by Daniel Cech on 21/03/2021.
//

import Foundation
import ScriptToolkit
import Stencil

/// Definition of stencil environment with support of custom filters
func stencilEnvironment() -> Environment {
    let ext = Extension()

    // First letter is capitalizad - in uppercase
    ext.registerFilter("decapitalized") { (value: Any?) in
        if let value = value as? String {
            return value.decapitalized()
        }

        return value
    }

    // First letter is decapitalized - in lowercase
    ext.registerFilter("capitalized") { (value: Any?) in
        if let value = value as? String {
            return value.capitalized()
        }

        return value
    }
    
    // First letter is capitalizad - in uppercase
    ext.registerFilter("uppercased") { (value: Any?) in
        if let value = value as? String {
            return value.uppercased()
        }

        return value
    }

    // First letter is decapitalized - in lowercase
    ext.registerFilter("lowercased") { (value: Any?) in
        if let value = value as? String {
            return value.lowercased()
        }

        return value
    }
    
    // If input is not empty, the comma and space is added
    ext.registerFilter("comma") { (value: Any?) in
        if let value = value as? String {
            return value.isEmpty ? "" : value + ", "
        }

        return value
    }
    
    ext.registerFilter("replace") { (value: Any?, arguments: [Any]) in
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
    
    let environment = Environment(loader: nil, extensions: [ext])
    return environment
}
