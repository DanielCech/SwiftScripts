//
//  ColorPalette.swift
//  stylesheetHelper
//
//  Created by Daniel Cech on 15/06/2020.
//

import Foundation

// MARK: - Image JSON structs

import AppKit
import Files
import Foundation
import ScriptToolkit
import SwiftShell

enum ColorAppearance: String {
    case light
    case dark
}

typealias ColorDefinition = (name: String, hexCode: String, appearance: ColorAppearance)

public extension String {
    func paddedToWidth(_ width: Int) -> String {
        let length = count
        guard length < width else {
            return self
        }

        let spaces = Array<Character>.init(repeating: " ", count: width - length)
        return self + spaces
    }
}

/// Structure of Contents.json
struct ColorMetadata: Codable {
    var colors: [ColorInfo]
}

/// Image description structure
struct ColorInfo: Codable {
    var idiom: String
    var color: Color?
    var appearances: [Appearance]?
}

struct Color: Codable {
    var colorSpace: String?
    var components: ColorComponents
}

struct ColorComponents: Codable {
    var red: String
    var green: String
    var blue: String
    var alpha: String
}

struct Appearance: Codable {
    var appearance: String?
    var value: String?
}

/// Getting information about the app icon images
func appColorsMetadata(iconFolder: Folder) throws -> ColorMetadata {
    let contentsFile = try iconFolder.file(named: "Contents.json")
    let jsonData = try contentsFile.read()
    do {
        let iconMetadata = try JSONDecoder().decode(ColorMetadata.self, from: jsonData)
        return iconMetadata
    }
    catch {
        print(error)
    }
    fatalError()
}

func colorComponent(string: String) -> CGFloat {
    // Hexa format
    if string.starts(with: "0x") {
        let hexCode = string[2...]
        if let value = UInt8(hexCode, radix: 16) {
            return CGFloat(value) / 255.0
        }
        else {
            return 0
        }
    }

    let floatValue: CGFloat = CGFloat((string as NSString).floatValue)

    if floatValue <= 1 {
        return floatValue
    }
    else {
        return floatValue / 255.0
    }
}

func showColorDescription(name: String, colorMetadata: ColorMetadata) -> [ColorDefinition] {
    var colorDefinitions = [ColorDefinition]()

    for color in colorMetadata.colors {
        guard let unwrappedColor = color.color else { continue }

        let redFloat: CGFloat = colorComponent(string: unwrappedColor.components.red)
        let greenFloat: CGFloat = colorComponent(string: unwrappedColor.components.green)
        let blueFloat: CGFloat = colorComponent(string: unwrappedColor.components.blue)
        let alphaFloat: CGFloat = colorComponent(string: unwrappedColor.components.alpha)

        let generatedColor = NSColor(deviceRed: redFloat, green: greenFloat, blue: blueFloat, alpha: alphaFloat)

        if let appearance = color.appearances?.first, let value = appearance.value, value == "dark" {
            colorDefinitions.append((name: name, hexCode: generatedColor.toHexString().uppercased(), appearance: .dark))
        }
        else {
            colorDefinitions.append((name: name, hexCode: generatedColor.toHexString().uppercased(), appearance: .light))
        }
    }

    return colorDefinitions
}

// =======================================================

// MARK: - Main script

func loadColorPalette() throws -> [String: [ColorDefinition]] {
    let inputFolder = try Folder(path: projectFolder)

    guard let appColorsFolder = inputFolder.findFirstFolder(name: "App Colors") else {
        throw ScriptError.argumentError(message: "App Colors folder not found in current dir and subdirs.")
    }

    var colorDefinitions = [ColorDefinition]()

    for folder in appColorsFolder.subfolders {
        guard folder.name.pathExtension.lowercased() == "colorset" else { continue }
        let colorMetadata = try appColorsMetadata(iconFolder: folder)

        colorDefinitions.append(contentsOf: showColorDescription(name: folder.nameExcludingExtension, colorMetadata: colorMetadata))
    }

    let codeDict = Dictionary(grouping: colorDefinitions, by: { $0.hexCode })

    return codeDict
}
