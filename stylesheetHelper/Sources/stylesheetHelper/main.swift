import Foundation

let projectFolder = "/Users/danielcech/Documents/[Development]/[Projects]/harbor-iOS"

let textInput =
"""
/* 202-712-6193 */


position: static;
width: 249px;
height: 19px;
left: 0px;
top: 80px;

font-family: SF Pro Display;
font-style: normal;
font-weight: normal;
font-size: 16px;
line-height: 19px;
/* identical to box height */


/* Navy */

color: #1B1F2B;

/* Inside Auto Layout */

flex: none;
order: 2;
align-self: flex-start;
margin: 0px 12px;
"""
var colorPalette = try loadColorPalette()
print(style(css: textInput))
