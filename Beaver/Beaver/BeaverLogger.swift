import OSLog
import Foundation

/**
 * BeaverLogger is the core logging engine of the Beaver framework.
 *
 * This class provides a comprehensive logging solution that combines performance,
 * thread safety, and seamless integration with Apple's unified logging system (OSLog).
 * It serves as the central hub for all logging operations and manages multiple
 * output destinations through the LogSink protocol.
 *
 * ## Key Features
 *
 * ### Thread Safety
 * - All operations are thread-safe using NSLock for logger cache management
 * - Async logging operations prevent blocking the calling thread
 * - Concurrent access to loggers is properly synchronized
 *
 * ### Performance Optimization
 * - Uses `@autoclosure` parameters for lazy message evaluation
 * - Early log level filtering to avoid unnecessary processing
 * - Efficient logger caching to reduce OSLog instance creation overhead
 *
 * ### OSLog Integration
 * - Automatic integration with Apple's unified logging system
 * - Tag-specific logger creation for proper categorization
 * - Preserves subsystem and category information for Console.app and Instruments
 *
 * ### Extensible Architecture
 * - Supports multiple custom LogSink implementations
 * - Protocol-based design allows for custom output destinations
 * - Flexible tag system for organized log categorization
 *
 * ## Usage Example
 *
 * ```swift
 * let logger = BeaverLoggerBuilder()
 *     .setLogLevel(.info)
 *     .addLogSink(ConsoleLogSink())
 *     .addLogSink(FileLogSink(fileURL: logFileURL))
 *     .build()
 *
 * let networkTag = NetworkTag()
 * logger.info(tag: networkTag, message: "API request completed")
 * logger.error(tag: networkTag, message: "Network request failed: \(error)")
 * ```
 *
 * ## Architecture Notes
 *
 * The logger maintains an internal cache of OSLog Logger instances, one per unique
 * tag (subsystem + category combination). This ensures optimal performance while
 * maintaining proper log categorization in Apple's logging system.
 *
 * All log operations are performed asynchronously on a dedicated queue to ensure
 * that logging never blocks application execution, even when multiple sinks are
 * configured or when performing expensive operations like file I/O.
 *
 * - Important: This class conforms to Sendable to support Swift's concurrency model
 * - Note: Logger instances are cached and reused for performance optimization
 * - Version: 1.0.0
 * - Since: iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0
 */
public final class BeaverLogger: LogSink, Sendable {
    /// The minimum log level for messages to be processed by this logger
    private let logLevel: LogLevel
    
    /// Array of custom log sinks that will receive log messages
    private let logSinks: [LogSink]
    
    /// Cache of OSLog Logger instances for different tags (thread-unsafe, protected by lock)
    nonisolated(unsafe) private var loggers = [String: Logger]()
    
    /// Lock for thread-safe access to the loggers cache
    private let loggersLock = NSLock()
    
    /// Dedicated queue for async log processing to avoid blocking callers
    private let queue = DispatchQueue(label: "com.beaver.logging", qos: .utility)
    
    /**
     * Initializes a new BeaverLogger instance.
     *
     * - Parameters:
     *   - logLevel: The minimum log level for messages to be processed
     *   - logSinks: Array of log sinks that will receive log messages
     *   - loggers: Pre-existing logger cache (used internally, defaults to empty)
     *
     * - Note: This initializer is internal and should be called through BeaverLoggerBuilder
     */
    init(logLevel: LogLevel, logSinks: [LogSink], loggers: [String : Logger] = [String: Logger]()) {
        self.logLevel = logLevel
        self.logSinks = logSinks
        self.loggers = loggers
    }

    // MARK: - Public Logging Methods
    
    /**
     * Logs a debug message with the specified tag.
     *
     * Debug messages provide detailed information for debugging purposes and are
     * typically filtered out in production builds. The message is lazily evaluated
     * using @autoclosure, so expensive string operations are only performed if
     * the debug level is enabled.
     *
     * - Parameters:
     *   - tag: The log tag for categorization and OSLog integration
     *   - message: The log message (lazily evaluated)
     *   - file: Source file name (automatically captured)
     *   - line: Source line number (automatically captured)
     *
     * - Note: Message will be filtered out if logger's level is higher than debug
     */
    public func debug(tag: any LogTag, message: @autoclosure () -> String, file: String = #file, line: Int = #line) {
        writeLog(logLevel: .debug, logTag: tag, message: message(), file: file, line: line)
    }
    
    /**
     * Logs an informational message with the specified tag.
     *
     * Info messages provide general information about application flow and
     * important events. These are typically kept in production logs for
     * monitoring and analysis purposes.
     *
     * - Parameters:
     *   - tag: The log tag for categorization and OSLog integration
     *   - message: The log message (lazily evaluated)
     *   - file: Source file name (automatically captured)
     *   - line: Source line number (automatically captured)
     */
    public func info(tag: any LogTag, message: @autoclosure () -> String, file: String = #file, line: Int = #line) {
        writeLog(logLevel: .info, logTag: tag, message: message(), file: file, line: line)
    }
    
    /**
     * Logs a warning message with the specified tag.
     *
     * Warning messages indicate potentially harmful situations that don't
     * prevent the application from continuing. These should be monitored
     * for potential issues that might need attention.
     *
     * - Parameters:
     *   - tag: The log tag for categorization and OSLog integration
     *   - message: The log message (lazily evaluated)
     *   - file: Source file name (automatically captured)
     *   - line: Source line number (automatically captured)
     */
    public func warning(tag: any LogTag, message: @autoclosure () -> String, file: String = #file, line: Int = #line) {
        writeLog(logLevel: .warning, logTag: tag, message: message(), file: file, line: line)
    }
    
    /**
     * Logs an error message with the specified tag.
     *
     * Error messages indicate error events that might affect application
     * functionality. These are the highest priority log messages and should
     * always be captured and monitored.
     *
     * - Parameters:
     *   - tag: The log tag for categorization and OSLog integration
     *   - message: The log message (lazily evaluated)
     *   - file: Source file name (automatically captured)
     *   - line: Source line number (automatically captured)
     */
    public func error(tag: any LogTag, message: @autoclosure () -> String, file: String = #file, line: Int = #line) {
        writeLog(logLevel: .error, logTag: tag, message: message(), file: file, line: line)
    }
    
    // MARK: - LogSink Implementation
    
    /**
     * Core logging method that processes and distributes log messages.
     *
     * This method implements the LogSink protocol and serves as the central
     * processing point for all log messages. It performs level filtering,
     * distributes messages to custom sinks, and integrates with OSLog.
     *
     * ## Processing Flow:
     * 1. **Level Filtering**: Messages below the configured level are discarded
     * 2. **Async Processing**: All processing happens on a background queue
     * 3. **Sink Distribution**: Messages are sent to all configured custom sinks
     * 4. **OSLog Integration**: Messages are forwarded to appropriate OSLog logger
     *
     * - Parameters:
     *   - logLevel: The severity level of the log message
     *   - logTag: Tag for categorization and OSLog subsystem/category
     *   - message: The formatted log message string
     *   - file: Source file where the log was called
     *   - line: Line number where the log was called
     *
     * - Note: This method is called by all public logging methods and custom sinks
     */
    public func writeLog(logLevel: LogLevel, logTag: any LogTag, message: String, file: String, line: Int) {
        // Add log level filtering - only log if message level is >= configured level
        guard logLevel.level >= self.logLevel.level else { return }
        
        queue.async { [weak self] in
            guard let self = self else { return }
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
    
    /**
     * Retrieves or creates an OSLog Logger instance for the specified tag.
     *
     * This method manages a cache of Logger instances to avoid the overhead
     * of creating new loggers for each message. Each unique combination of
     * subsystem and category gets its own Logger instance for proper
     * categorization in Apple's logging system.
     *
     * ## Thread Safety
     * Access to the logger cache is protected by NSLock to ensure thread safety
     * in concurrent logging scenarios.
     *
     * ## Cache Key
     * Logger instances are cached using the key format: "{subsystem}.{category}"
     *
     * - Parameter tag: The log tag containing subsystem and category information
     * - Returns: A cached or newly created Logger instance for the tag
     *
     * - Note: Logger instances are retained for the lifetime of the BeaverLogger
     */
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
    
    /**
     * Formats a log prefix with level, filename, and line number information.
     *
     * This method creates a consistent prefix format for log messages that
     * includes the log level name, source filename (without full path), and
     * line number. This information is useful for debugging and tracing.
     *
     * ## Format
     * The returned prefix follows the format: "[LEVEL] filename.swift:123"
     *
     * - Parameters:
     *   - logLevel: The log level for name extraction
     *   - file: Full file path (will be reduced to filename only)
     *   - line: Line number where the log was called
     * - Returns: Formatted prefix string ready for inclusion in log messages
     *
     * - Note: Only the filename is included, not the full path, for readability
     */
    private func formattedPrefix(logLevel: LogLevel, file: String, line: Int) -> String {
        let filename = URL(fileURLWithPath: file).lastPathComponent
        return "[\(logLevel.name)] \(filename):\(line)"
    }
}
