import Foundation
import Files

let projectFolder = Folder.current.path

print("🟢 Enter CSS style (finish last line with `zzz`):")

var textInput = ""
while let line = readLine(strippingNewline: false) {
    if line.starts(with: "zzz") { break }
    textInput += line
}

var colorPalette = try loadColorPalette()
print("\n💡 Stylesheet definition:")
print(style(css: textInput))
print("")
