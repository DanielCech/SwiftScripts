//
//  CSSTranslator.swift
//  stylesheetHelper
//
//  Created by Daniel Cech on 15/06/2020.
//

import Foundation

func style(css textInput: String) -> String {
    var fontName: String?
    var fontSize: String?
    var fontWeight: String?
    var alignment: String?
    var color: String?
    var lineHeight: String?
    var letterSpacing: String?
    
    for line in textInput.split(separator: "\n") {
        var lineElements = line.split(separator: ":").map { String($0) }
        lineElements = lineElements.map { $0.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines.union(CharacterSet(charactersIn: ";"))) }
        
        switch lineElements[0] {
        case "font-family":
            fontName = lineElements[1]
            if lineElements[1].contains(" ") {
                var nameParts = lineElements[1].split(separator: " ").map { String($0) }
                nameParts[0] = nameParts[0].lowercased()
                fontName = nameParts.joined(separator: "")
            }
            fontName = fontName?.replacingOccurrences(of: "-", with: "").decapitalizingFirstLetter()
            
        case "font-weight":
            fontWeight = lineElements[1]
            if fontWeight == "normal" {
                fontWeight = "regular"
            }
            fontWeight = fontWeight?.capitalizingFirstLetter()
        case "font-size":
            fontSize = lineElements[1].replacingOccurrences(of: "px", with: "")
        case "text-align":
            alignment = "." + lineElements[1].decapitalizingFirstLetter()
        case "line-height":
            lineHeight = lineElements[1].replacingOccurrences(of: "px", with: "")
        case "letter-spacing":
            letterSpacing = lineElements[1]
        case "color":
            color = lineElements[1]
        default:
            break
        }
    }
    
    // Postprocessing
    if alignment == nil {
        alignment = ".natural"
    }
    
    if fontWeight == nil {
        fontWeight = ""
    }
    
    if let unwrappedLineHeight = lineHeight,
       let unwrappedFontSize = fontSize,
       let lineHeightFloat = Float(unwrappedLineHeight),
       let fontSizeFloat = Float(unwrappedFontSize) {
        lineHeight = String(Double(lineHeightFloat / fontSizeFloat).rounded(toPlaces: 2))
    }
    else {
        lineHeight = nil
    }
    
    if letterSpacing == "0" {
        letterSpacing = nil
    }
    else if let unwrappedLetterSpacing = letterSpacing, unwrappedLetterSpacing.contains("em") {
        let stringValue = unwrappedLetterSpacing.replacingOccurrences(of: "em", with: "")
        
        if
            let floatValue = Float(stringValue),
            let unwrappedFontSize = fontSize,
            let floatFontSize = Float(unwrappedFontSize) {
            letterSpacing = String(Double(floatValue * floatFontSize).rounded(toPlaces: 2))
        }
        else {
            letterSpacing = nil
        }
    }
    
    if let unwrappedColor = color?.uppercased() {
        if let unwrappedColorRecord = colorPalette[unwrappedColor],
           let unwrappedColorName = unwrappedColorRecord.first(where: { $0.appearance == .light }) {
            color = unwrappedColorName.name
        }
        else {
            color = nil
            print("Warning: color definition \(unwrappedColor) is missing")
        }
    }
    else {
        color = nil
    }
    
    // Formatting output
    var elements = [String]()
    
    if let unwrappedFontName = fontName, let unwrappedFontWeight = fontWeight, let unwrappedFontSize = fontSize {
        elements.append("fontStyle(R.font.\(unwrappedFontName)\(unwrappedFontWeight)(size: \(unwrappedFontSize))!)")
    }
    
    if let unwrappedAlignment = alignment {
        elements.append("alignmentStyle(\(unwrappedAlignment))")
    }
    
    if let unwrappedLineHeight = lineHeight {
        elements.append("paragraphLineHeightMultipleStyle(\(unwrappedLineHeight))")
    }
    
    if let unwrappedLetterSpacing = letterSpacing {
        elements.append("kernStyle(\(unwrappedLetterSpacing))")
    }
    
    if let unwrappedColor = color {
        elements.append("colorStyle(R.color.appColors.\(unwrappedColor)()!)")
    }
    
    let output = "return " + elements.joined(separator: "\n    <> ")
    
    return output
}
