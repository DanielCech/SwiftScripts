import Foundation
import SwiftShell

public class InputStream: ReadableStream {
    public var encoding: String.Encoding
    
    public var filehandle: FileHandle
    
    init() {
        filehandle = FileHandle()
    }
}

public struct CustomContext: Context, CommandRunning {
    public var env: [String: String]
    public var currentdirectory: String
    public var stdin: ReadableStream
    public var stdout: WritableStream
    public var stderror: WritableStream
}

let input =  InputStream()

let context = CustomContext(


print("Hello, world!")

try runAndPrint("swift")

runAsync("/usr/bin/swift").context

//let command = runAsync("/usr/bin/swift").onCompletion { command in
//    print("command completed")
//}
//command.stdout.onOutput { stdout in
//    print("new output \(stdout.read())")
//
//}
//
//// do something with ‘command’ while it is still running.
//
////try command.finish() // wait for it to finish.
//
//while true {}
