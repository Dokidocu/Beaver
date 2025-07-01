/**
 * Beavy provides a global, static interface to the Beaver logging framework.
 *
 * This enum serves as the main entry point for logging operations throughout your
 * application. It maintains a default logger instance that can be configured once
 * and used consistently across your entire codebase without the need to pass
 * logger instances around.
 *
 * ## Key Features
 *
 * ### Global Access
 * - Static methods provide easy access from anywhere in your application
 * - No need to pass logger instances between classes and methods
 * - Consistent logging interface across your entire codebase
 *
 * ### Lazy Configuration
 * - Default logger is created with sensible defaults
 * - Can be reconfigured at any time using the configure method
 * - Configuration typically happens once during application startup
 *
 * ### Performance Optimized
 * - Uses @autoclosure for lazy message evaluation
 * - Thread-safe access to the underlying logger instance
 * - Minimal overhead for disabled log levels
 *
 * ## Usage Examples
 *
 * ### Basic Logging
 * ```swift
 * import Beaver
 *
 * let networkTag = NetworkTag()
 * Beavy.info(tag: networkTag, message: "API request started")
 * Beavy.error(tag: networkTag, message: "Request failed: \(error)")
 * ```
 *
 * ### Configuration
 * ```swift
 * // Configure during app startup
 * Beavy.configure(with: BeaverLoggerBuilder()
 *     .setLogLevel(.info)
 *     .addLogSink(ConsoleLogSink())
 *     .addLogSink(FileLogSink(fileURL: logFileURL))
 * )
 * ```
 *
 * ## Architecture Notes
 *
 * The global logger instance is stored as a static variable and is thread-safe
 * for concurrent access. The nonisolated(unsafe) annotation is used because
 * the underlying BeaverLogger is designed to be Sendable and thread-safe.
 *
 * This design provides the convenience of global access while maintaining the
 * flexibility and power of the underlying BeaverLogger architecture.
 *
 * - Important: Configure the logger early in your application lifecycle
 * - Note: The enum pattern prevents instantiation while providing namespace
 * - Version: 1.0.0
 * - Since: iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0
 */
public enum Beavy {
    /// The shared default logger instance (thread-safe, managed internally)
    nonisolated(unsafe) private static var defaultLogger = BeaverLoggerBuilder().build()

    /**
     * Configures the global logger with custom settings.
     *
     * This method allows you to replace the default logger configuration with
     * a custom setup. It should typically be called once during application
     * startup to establish your preferred logging configuration.
     *
     * ## Configuration Example
     * ```swift
     * Beavy.configure(with: BeaverLoggerBuilder()
     *     .setLogLevel(.warning)  // Only warnings and errors in production
     *     .addLogSink(ConsoleLogSink())
     *     .addLogSink(FileLogSink(fileURL: logFileURL))
     * )
     * ```
     *
     * - Parameter builder: A configured BeaverLoggerBuilder instance
     *
     * - Important: Call this method before any logging operations for consistent behavior
     * - Note: This operation is thread-safe and can be called from any queue
     */
    public static func configure(with builder: BeaverLoggerBuilder) {
        Self.defaultLogger = builder.build()
    }

    /**
     * Logs a debug message using the global logger.
     *
     * Debug messages provide detailed information for debugging purposes.
     * The message is lazily evaluated, so expensive string operations are
     * only performed if debug logging is enabled.
     *
     * - Parameters:
     *   - tag: Log tag for categorization and OSLog integration
     *   - message: The log message (lazily evaluated with @autoclosure)
     *
     * - Note: Message may be filtered out if global logger level is above debug
     */
    public static func debug(tag: LogTag, message: @autoclosure () -> String) {
        Self.defaultLogger.debug(tag: tag, message: message())
    }

    /**
     * Logs an informational message using the global logger.
     *
     * Info messages provide general information about application flow
     * and important events. These are suitable for production logging.
     *
     * - Parameters:
     *   - tag: Log tag for categorization and OSLog integration
     *   - message: The log message (lazily evaluated with @autoclosure)
     */
    public static func info(tag: LogTag, message: @autoclosure () -> String) {
        defaultLogger.info(tag: tag, message: message())
    }

    /**
     * Logs a warning message using the global logger.
     *
     * Warning messages indicate potentially harmful situations that don't
     * prevent the application from continuing but should be monitored.
     *
     * - Parameters:
     *   - tag: Log tag for categorization and OSLog integration
     *   - message: The log message (lazily evaluated with @autoclosure)
     */
    public static func warning(tag: LogTag, message: @autoclosure () -> String) {
        defaultLogger.warning(tag: tag, message: message())
    }

    /**
     * Logs an error message using the global logger.
     *
     * Error messages indicate error events that affect application functionality.
     * These are the highest priority messages and should always be captured.
     *
     * - Parameters:
     *   - tag: Log tag for categorization and OSLog integration
     *   - message: The log message (lazily evaluated with @autoclosure)
     */
    public static func error(tag: LogTag, message: @autoclosure () -> String) {
        defaultLogger.error(tag: tag, message: message())
    }
}
