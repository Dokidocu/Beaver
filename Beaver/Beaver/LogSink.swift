import Foundation

/**
 * LogSink defines the protocol for custom log output destinations in the Beaver framework.
 *
 * This protocol enables the creation of custom log destinations that can receive
 * and process log messages in any desired format or location. Implementations
 * can send logs to files, network endpoints, databases, analytics services,
 * or any other destination.
 *
 * ## Key Features
 *
 * ### Extensible Architecture
 * - Simple protocol interface for easy implementation
 * - Supports any output destination or format
 * - Can be chained with other sinks for multiple outputs
 * - Thread-safe design with Sendable conformance
 *
 * ### Rich Context Information
 * - Access to log level for severity-based processing
 * - Tag information for categorization and filtering
 * - Source file and line number for debugging
 * - Raw message string for flexible formatting
 *
 * ### Performance Considerations
 * - Called on background queues to avoid blocking
 * - Receives pre-filtered messages based on logger configuration
 * - Can implement additional filtering logic as needed
 *
 * ## Implementation Examples
 *
 * ### File Logging Sink
 * ```swift
 * struct FileLogSink: LogSink {
 *     private let fileURL: URL
 *     
 *     func writeLog(logLevel: LogLevel, logTag: any LogTag, message: String, file: String, line: Int) {
 *         let timestamp = ISO8601DateFormatter().string(from: Date())
 *         let logEntry = "[\(timestamp)] [\(logLevel.name)] \(message)\n"
 *         try? logEntry.appendToFile(at: fileURL)
 *     }
 * }
 * ```
 *
 * ### Network Logging Sink
 * ```swift
 * struct NetworkLogSink: LogSink {
 *     private let endpoint: URL
 *     
 *     func writeLog(logLevel: LogLevel, logTag: any LogTag, message: String, file: String, line: Int) {
 *         let payload = [
 *             "level": logLevel.name,
 *             "message": message,
 *             "subsystem": logTag.subsystem,
 *             "category": logTag.name
 *         ]
 *         sendToServer(payload, to: endpoint)
 *     }
 * }
 * ```
 *
 * ## Usage in Logger Configuration
 *
 * ```swift
 * let logger = BeaverLoggerBuilder()
 *     .addLogSink(ConsoleLogSink())
 *     .addLogSink(FileLogSink(fileURL: logFileURL))
 *     .addLogSink(NetworkLogSink(endpoint: analyticsURL))
 *     .build()
 * ```
 *
 * ## Thread Safety
 *
 * LogSink implementations must be thread-safe as they will be called from
 * background queues. The protocol conforms to Sendable to ensure safe
 * concurrent access in Swift's concurrency model.
 *
 * ## Error Handling
 *
 * LogSink implementations should handle errors gracefully and avoid throwing
 * exceptions that could disrupt the logging pipeline. Failed sink operations
 * should not affect other sinks or the overall logging system.
 *
 * - Important: Implementations must be thread-safe and non-blocking
 * - Note: Called on background queues, not the main thread
 * - Version: 1.0.0
 * - Since: iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0
 */
public protocol LogSink: Sendable {
    /**
     * Processes and outputs a log message to the sink's destination.
     *
     * This method is called by the logging framework for each log message that
     * passes through the system. Implementations should process the provided
     * information and output it to their specific destination (file, network,
     * console, database, etc.).
     *
     * ## Parameters Overview
     *
     * All parameters provide context and metadata about the log message:
     *
     * - **logLevel**: Severity level for filtering and formatting decisions
     * - **logTag**: Categorization information (subsystem, category)
     * - **message**: The actual log message content (pre-formatted)
     * - **file**: Source file path for debugging context
     * - **line**: Source line number for debugging context
     *
     * ## Implementation Guidelines
     *
     * ### Thread Safety
     * - This method will be called from background queues
     * - Implementations must be thread-safe
     * - Avoid blocking operations when possible
     *
     * ### Error Handling
     * - Handle errors gracefully without throwing exceptions
     * - Log sink failures should not affect other sinks
     * - Consider fallback mechanisms for critical logging
     *
     * ### Performance
     * - Optimize for high-throughput scenarios
     * - Consider batching for network or database operations
     * - Implement appropriate buffering strategies
     *
     * ## Example Implementation
     *
     * ```swift
     * func writeLog(logLevel: LogLevel, logTag: any LogTag, message: String, file: String, line: Int) {
     *     let timestamp = Date()
     *     let filename = URL(fileURLWithPath: file).lastPathComponent
     *     let formattedMessage = "[\(timestamp)] [\(logLevel.name)] [\(logTag.name)] \(filename):\(line) - \(message)"
     *     
     *     // Output to your destination
     *     outputToDestination(formattedMessage)
     * }
     * ```
     *
     * - Parameters:
     *   - logLevel: The severity level of the log message
     *   - logTag: Tag containing subsystem and category information
     *   - message: The formatted log message string
     *   - file: Full path to the source file where the log was called
     *   - line: Line number in the source file where the log was called
     *
     * - Important: This method must be thread-safe and non-blocking
     * - Note: Called on background queues, not the main thread
     */
    func writeLog(logLevel: LogLevel, logTag: any LogTag, message: String, file: String, line: Int)
}
