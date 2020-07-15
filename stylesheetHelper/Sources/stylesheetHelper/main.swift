import Foundation

let projectFolder = "/Users/danielcech/Documents/[Development]/[Projects]/harbor-iOS"

let textInput =
"""
/* dan.loard@gmail.com */


position: absolute;
width: 153px;
height: 20px;
left: 111px;
top: 230px;

/* Defaut Body Text */

font-family: SF Pro Text;
font-style: normal;
font-weight: normal;
font-size: 15px;
line-height: 20px;
/* identical to box height, or 133% */

text-align: center;

/* Cool Grey */

color: #65727B;
"""
var colorPalette = try loadColorPalette()
print(style(css: textInput))
