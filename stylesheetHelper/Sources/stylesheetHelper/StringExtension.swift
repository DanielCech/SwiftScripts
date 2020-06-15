//
//  StringExtension.swift
//  CodeTemplates
//
//  Created by Daniel Cech on 13/06/2020.
//

import Foundation

public extension String {
    func capitalizingFirstLetter() -> String {
        let first = String(prefix(1)).uppercased()
        let other = String(dropFirst())
        return first + other
    }

    mutating func capitalizeFirstLetter() {
        self = capitalizingFirstLetter()
    }

    func decapitalizingFirstLetter() -> String {
        let first = String(prefix(1)).lowercased()
        let other = String(dropFirst())
        return first + other
    }

    mutating func decapitalizeFirstLetter() {
        self = decapitalizingFirstLetter()
    }
}
