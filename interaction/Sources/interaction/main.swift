//import AppKit
//
//let app = NSApplication.shared
//
//class AppDelegate: NSObject, NSApplicationDelegate {
//    let window = NSWindow(contentRect: NSMakeRect(200, 200, 400, 200),
//                          styleMask: [.titled, .closable, .miniaturizable, .resizable],
//                          backing: .buffered,
//                          defer: false,
//                          screen: nil)
//
//    func applicationDidFinishLaunching(_ notification: Notification) {
//        window.makeKeyAndOrderFront(nil)
//        let field = NSTextView(frame: window.contentView!.bounds)
//        field.backgroundColor = .white
//        field.isContinuousSpellCheckingEnabled = true
//        window.contentView?.addSubview(field)
//        DispatchQueue(label: "background").async {
//            while let str = readLine(strippingNewline: false) {
//                DispatchQueue.main.async {
//                    field.textStorage?.append(NSAttributedString(string: str))
//                }
//            }
//            app.terminate(self)
//        }
//    }
//}
//
//let delegate = AppDelegate()
//app.delegate = delegate
//app.run()


import AppKit

func selectFile() -> URL? {
    let dialog = NSOpenPanel()
    dialog.allowedFileTypes = ["jpg", "png"]
    guard dialog.runModal() == .OK else { return nil }
    return dialog.url
}

print(selectFile()?.absoluteString ?? "")
