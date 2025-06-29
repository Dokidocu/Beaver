import OSLog
import Foundation

public final class BeaverLogger: LogSink, @unchecked Sendable {
    private let logLevel: LogLevel
    private let logSinks: [LogSink]
    private var loggers = [String: Logger]()
    private let loggersLock = NSLock()
    private let queue = DispatchQueue(label: "com.beaver.logging", qos: .utility)
    
    init(logLevel: LogLevel, logSinks: [LogSink], loggers: [String : Logger] = [String: Logger]()) {
        self.logLevel = logLevel
        self.logSinks = logSinks
        self.loggers = loggers
    }

    // MARK: - Public Logging Methods
    
    public func debug(tag: any LogTag, message: @autoclosure () -> String, file: String = #file, line: Int = #line) {
        writeLog(logLevel: .debug, logTag: tag, message: message(), file: file, line: line)
    }
    
    public func info(tag: any LogTag, message: @autoclosure () -> String, file: String = #file, line: Int = #line) {
        writeLog(logLevel: .info, logTag: tag, message: message(), file: file, line: line)
    }
    
    public func warning(tag: any LogTag, message: @autoclosure () -> String, file: String = #file, line: Int = #line) {
        writeLog(logLevel: .warning, logTag: tag, message: message(), file: file, line: line)
    }
    
    public func error(tag: any LogTag, message: @autoclosure () -> String, file: String = #file, line: Int = #line) {
        writeLog(logLevel: .error, logTag: tag, message: message(), file: file, line: line)
    }
    
    // MARK: - LogSink Implementation
    
    public func writeLog(logLevel: LogLevel, logTag: any LogTag, message: String, file: String, line: Int) {
        // Add log level filtering - only log if message level is >= configured level
        guard logLevel.level >= self.logLevel.level else { return }
        
        queue.async {
            // Write to custom log sinks
            self.logSinks.forEach { logSink in
                logSink.writeLog(logLevel: logLevel, logTag: logTag, message: message, file: file, line: line)
            }
            
            // Write to OSLog with tag-specific logger
            let taggedLogger = self.getOrCreateLogger(for: logTag)
            taggedLogger.log(
                level: logLevel.osLogType,
                "\(logTag.prefix)\(self.formattedPrefix(logLevel: logLevel, file: file, line: line)) : \(message)"
            )
        }
    }
    
    // MARK: - Private Helper Methods
    
    private func getOrCreateLogger(for tag: any LogTag) -> Logger {
        let key = "\(tag.subsystem).\(tag.name)"
        
        loggersLock.lock()
        defer { loggersLock.unlock() }
        
        if let existingLogger = loggers[key] {
            return existingLogger
        }
        
        let newLogger = Logger(subsystem: tag.subsystem, category: tag.name)
        loggers[key] = newLogger
        return newLogger
    }
    
    private func formattedPrefix(logLevel: LogLevel, file: String, line: Int) -> String {
        let filename = URL(fileURLWithPath: file).lastPathComponent
        return "[\(logLevel.name)] \(filename):\(line)"
    }
}

// MARK: - Builder Pattern

public struct BeaverBuilder {
    private var logLevel: LogLevel = .debug
    private var logSinks: [LogSink] = []
    
    public init() {}
    
    public func setLogLevel(_ logLevel: LogLevel) -> BeaverBuilder {
        var builder = self
        builder.logLevel = logLevel
        return builder
    }
    
    public func addLogSink(_ logSink: LogSink) -> BeaverBuilder {
        var builder = self
        builder.logSinks.append(logSink)
        return builder
    }
    
    public func build() -> BeaverLogger {
        return BeaverLogger(logLevel: logLevel, logSinks: logSinks)
    }
}
