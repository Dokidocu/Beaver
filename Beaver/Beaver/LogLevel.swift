import OSLog

/**
 * LogLevel defines the severity levels for log messages in the Beaver framework.
 *
 * This enumeration provides a standard set of log levels that determine the
 * importance and severity of log messages. It integrates seamlessly with
 * Apple's OSLog system by providing appropriate type mappings.
 *
 * ## Log Level Hierarchy
 *
 * The levels are ordered by severity (lowest to highest):
 * 1. **Debug** (0): Detailed information for debugging
 * 2. **Info** (1): General informational messages
 * 3. **Warning** (2): Potentially harmful situations
 * 4. **Error** (3): Error events that might affect functionality
 *
 * ## Level Filtering
 *
 * Log levels are used for filtering messages. When a logger is configured
 * with a specific level, only messages at that level or higher will be
 * processed. For example, a logger set to `.warning` will process warning
 * and error messages but filter out debug and info messages.
 *
 * ## OSLog Integration
 *
 * Each Beaver log level maps to an appropriate OSLogType for integration
 * with Apple's unified logging system:
 *
 * - `.debug` → `OSLogType.debug`
 * - `.info` → `OSLogType.info`
 * - `.warning` → `OSLogType.default`
 * - `.error` → `OSLogType.error`
 *
 * ## Usage Examples
 *
 * ```swift
 * // Configure logger with specific level
 * let logger = BeaverLoggerBuilder()
 *     .setLogLevel(.warning)  // Only warnings and errors will be logged
 *     .build()
 *
 * // Check level programmatically
 * if logLevel.level >= LogLevel.error.level {
 *     // Handle high-priority logging
 * }
 * ```
 *
 * ## Performance Considerations
 *
 * Log level filtering happens early in the logging pipeline, providing
 * excellent performance characteristics. Messages below the configured
 * level are discarded before any expensive string formatting or I/O
 * operations occur.
 *
 * - Important: Higher numeric values indicate higher severity
 * - Note: Conforms to Sendable for safe use in concurrent contexts
 * - Version: 1.0.0
 * - Since: iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0
 */
public enum LogLevel: Int, CaseIterable, Sendable {
    /// Detailed information for debugging purposes (lowest priority)
    case debug = 0
    /// General informational messages about application flow
    case info = 1
    /// Potentially harmful situations that don't stop execution
    case warning = 2
    /// Error events that might affect application functionality (highest priority)
    case error = 3
    
    /**
     * The numeric level value for comparison and filtering.
     *
     * This property returns the raw integer value of the log level, which
     * can be used for numeric comparisons when implementing custom filtering
     * logic or determining message priority.
     *
     * - Returns: The integer value of the log level (0-3)
     */
    public var level: Int {
        return rawValue
    }
    
    /**
     * The corresponding OSLogType for Apple's unified logging system.
     *
     * This property maps Beaver log levels to appropriate OSLog types for
     * seamless integration with Apple's logging infrastructure. The mapping
     * ensures that messages appear correctly in Console.app, Instruments,
     * and other Apple debugging tools.
     *
     * ## Mapping Details:
     * - `.debug` → `OSLogType.debug` (verbose debugging information)
     * - `.info` → `OSLogType.info` (general information)
     * - `.warning` → `OSLogType.default` (standard messages, visible by default)
     * - `.error` → `OSLogType.error` (error conditions)
     *
     * - Returns: The appropriate OSLogType for this log level
     *
     * - Note: Warning level uses `.default` instead of `.fault` for better visibility
     */
    var osLogType: OSLogType {
        let result: OSLogType
        switch self {
        case .debug: result = OSLogType.debug
        case .info: result = OSLogType.info
        case .warning: result = OSLogType.default  // Changed from .fault for better mapping
        case .error: result = OSLogType.error
        }
        return result
    }
    
    /**
     * The human-readable name of the log level.
     *
     * This property provides a standardized string representation of the log
     * level that can be used in log formatting, user interfaces, or debugging
     * output. The names are uppercase for consistency and visibility.
     *
     * ## Level Names:
     * - `.debug` → "DEBUG"
     * - `.info` → "INFO"
     * - `.warning` → "WARNING"
     * - `.error` → "ERROR"
     *
     * - Returns: The uppercase string name of the log level
     *
     * - Note: These names are commonly used in log file formatting and console output
     */
    public var name: String {
        switch self {
        case .debug: return "DEBUG"
        case .info: return "INFO"
        case .warning: return "WARNING"
        case .error: return "ERROR"
        }
    }
}
