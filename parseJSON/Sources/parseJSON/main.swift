import Foundation
import os.log

extension OSLog {
    
    private static var subsystem = "parseJSON"

    /// Logs the view cycles like viewDidLoad.
    static let common = OSLog(subsystem: subsystem, category: "common")
    
    static func log(_ message: String, log: OSLog = common, type: OSLogType = .default) {
        os_log("%{public}@", log: log, type: type, message)
    }
}

extension Collection {
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

/// Convert text to dictionary
func convertToDictionary(text: String) -> [String: Any]? {
    if let data = text.data(using: .utf8) {
        do {
            return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        } catch {
            OSLog.log(error.localizedDescription)
        }
    }
    return nil
}


guard
    let jsonString = CommandLine.arguments[safe: 1],
    let keyPath = CommandLine.arguments[safe: 2]
else {
    print("Usage:   parseJSON <JSON string> <The keypath>")
    print(#"Example: parseJSON '{"result": {"url": "http://google.com"}}' result,url"#)
    exit(1)
}

guard var jsonDict = convertToDictionary(text: jsonString) else {
    OSLog.log("Error: Invalid JSON")
    exit(1)
}


var result: String?

for key in keyPath.components(separatedBy: ",") {
    if let subJsonString = jsonDict[key] as? String {
        result = subJsonString
    }
    else if let subJsonDict = jsonDict[key] as? [String: Any] {
        jsonDict = subJsonDict
    }
    else {
        OSLog.log("Error: Invalid JSON path")
        exit(1)
    }
}

if let unwrappedResult = result {
    print(unwrappedResult)
}
else {
    OSLog.log("Error: Empty result")
    exit(1)
}

exit(0)


