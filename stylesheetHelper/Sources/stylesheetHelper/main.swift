import Foundation

let textInput =
"""
/* Household Emergency Plan */


position: absolute;
width: 214px;
height: 76px;
left: 80px;
top: 77px;

/* Serif H1 Heading */

font-family: DM Serif Display;
font-style: normal;
font-weight: normal;
font-size: 30px;
line-height: 38px;
/* or 127% */

text-align: center;

/* Navy */

color: #1B1F2B;
"""

var fontName: String?
var fontSize: String?
var fontWeight: String?
var alignment: String?
var color: String?
var lineHeight: String?

for line in textInput.split(separator: "\n") {
    var lineElements = line.split(separator: ":").map { String($0) }
    lineElements = lineElements.map { $0.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines.union(CharacterSet(charactersIn: ";"))) }
    
    switch lineElements[0] {
    case "font-family":
        fontName = lineElements[1].replacingOccurrences(of: " ", with: "").decapitalizingFirstLetter()
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
    default:
        break
    }
}

// Postprocessing
if alignment == nil {
    alignment = ".left"
}

if let unwrappedLineHeight = lineHeight,
    let unwrappedFontSize = fontSize,
    let lineHeightFloat = Float(unwrappedLineHeight),
    let fontSizeFloat = Float(unwrappedFontSize)
{
    lineHeight = String(Double(lineHeightFloat / fontSizeFloat).rounded(toPlaces: 2))
}
else {
    lineHeight = nil
}

// Formatting output
var output = "                return "
if let unwrappedFontName = fontName, let unwrappedFontWeight = fontWeight, let unwrappedFontSize = fontSize {
    output += "fontStyle(R.font.\(unwrappedFontName)\(unwrappedFontWeight)(size: \(unwrappedFontSize))\n"
}

if let unwrappedAlignment = alignment {
    output += "                    <> alignmentStyle(\(unwrappedAlignment))\n"
}

if let unwrappedLineHeight = lineHeight {
    output += "                    <> paragraphLineHeightMultipleStyle(\(unwrappedLineHeight))\n"
}

print(output)
