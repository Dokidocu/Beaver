import Foundation

public protocol LogSink: Sendable {
    func writeLog(logLevel: LogLevel, logTag: any LogTag, message: String, file: String, line: Int)
}
