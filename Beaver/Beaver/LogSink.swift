import Foundation

public protocol LogSink: Sendable {
    func writeLog(logLevel: LogLevel, logTag: any LogTag, message: String, file: String, line: Int)
}

// Console Log Sink - prints to console
public struct ConsoleLogSink: LogSink {
    
    public init() {}
    
    public func writeLog(logLevel: LogLevel, logTag: any LogTag, message: String, file: String, line: Int) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        let timestamp = dateFormatter.string(from: Date())
        let filename = URL(fileURLWithPath: file).lastPathComponent
        let logMessage = "\(timestamp) \(logTag.prefix)[\(logLevel.name)] \(filename):\(line) - \(message)"
        print(logMessage)
    }
}

// File Log Sink - writes to file
public struct FileLogSink: LogSink {
    private let fileURL: URL
    private let dateFormatter: DateFormatter
    private let queue = DispatchQueue(label: "com.beaver.file.logging", qos: .utility)
    
    public init(fileURL: URL) {
        self.fileURL = fileURL
        self.dateFormatter = DateFormatter()
        self.dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        
        // Create file if it doesn't exist
        if !FileManager.default.fileExists(atPath: fileURL.path) {
            FileManager.default.createFile(atPath: fileURL.path, contents: nil, attributes: nil)
        }
    }
    
    public func writeLog(logLevel: LogLevel, logTag: any LogTag, message: String, file: String, line: Int) {
        queue.async {
            let timestamp = self.dateFormatter.string(from: Date())
            let filename = URL(fileURLWithPath: file).lastPathComponent
            let logMessage = "\(timestamp) \(logTag.prefix)[\(logLevel.name)] \(filename):\(line) - \(message)\n"
            
            if let data = logMessage.data(using: .utf8) {
                if let fileHandle = try? FileHandle(forWritingTo: self.fileURL) {
                    fileHandle.seekToEndOfFile()
                    fileHandle.write(data)
                    fileHandle.closeFile()
                }
            }
        }
    }
}
