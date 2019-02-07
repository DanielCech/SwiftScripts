import SwiftShell

if main.arguments.count >= 2 {
    let inFileName = main.arguments[0]
    let outFileName = main.arguments[1]
    let size = Int(main.arguments[2]) ?? 0
    
    run("convert", "\(inFileName)", "-resize", "\(size)x\(size)", "\(outFileName).png")
    run("convert", "\(inFileName)", "-resize", "\(size * 2)x\(size * 2)", "\(outFileName)@2x.png")
    run("convert", "\(inFileName)", "-resize", "\(size * 3)x\(size * 3)", "\(outFileName)@3x.png")
}
else {
    print("Use: marathon run ResizeIcon <input file> <output file> <size>")
}


