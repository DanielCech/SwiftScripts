import Foundation

let projectFolder = "/Users/danielcech/Documents/[Development]/[Projects]/harbor-iOS"

let textInput =
"""
font-family: Helvetica;
font-size: 14px;
color: #656566;
letter-spacing: 0;
text-align: center;
line-height: 24px;
"""
var colorPalette = try loadColorPalette()
print(style(css: textInput))
