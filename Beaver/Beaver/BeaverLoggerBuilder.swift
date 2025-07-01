//
//  BeaverLoggerBuilder.swift
//  Beaver
//
//  Created by Henri La on 29.06.2025.
//

import Foundation

// MARK: - Builder Pattern

/**
 * A builder class for constructing `BeaverLogger` instances with customizable configuration.
 *
 * `BeaverLoggerBuilder` implements the Builder design pattern to provide a fluent, chainable API
 * for configuring and creating `BeaverLogger` instances. This approach ensures type safety,
 * immutability, and clear configuration flow while maintaining flexibility in logger setup.
 *
 * ## Design Pattern
 * The builder pattern is used here to:
 * - Provide a fluent, readable configuration API
 * - Ensure type safety during configuration
 * - Allow step-by-step construction of complex logger configurations
 * - Support method chaining for concise setup code
 * - Maintain immutability of the builder state
 *
 * ## Thread Safety
 * This builder is **not thread-safe**. Each builder instance should be used from a single thread.
 * However, the built `BeaverLogger` instances are thread-safe once created.
 *
 * ## Usage Examples
 * ```swift
 * // Basic logger with default settings
 * let basicLogger = BeaverLoggerBuilder()
 *     .build()
 *
 * // Logger with custom log level
 * let infoLogger = BeaverLoggerBuilder()
 *     .setLogLevel(.info)
 *     .build()
 *
 * // Logger with multiple sinks
 * let productionLogger = BeaverLoggerBuilder()
 *     .setLogLevel(.warning)
 *     .addLogSink(ConsoleLogSink())
 *     .addLogSink(FileLogSink(fileURL: logFileURL))
 *     .build()
 *
 * // Complex configuration
 * let logger = BeaverLoggerBuilder()
 *     .setLogLevel(.debug)
 *     .addLogSink(ConsoleLogSink())
 *     .addLogSink(FileLogSink(fileURL: logFileURL))
 *     .addLogSink(RemoteLogSink(endpoint: apiEndpoint))
 *     .build()
 * ```
 *
 * ## Performance Considerations
 * - Builder operations are lightweight value-type operations
 * - Each method call creates a new builder instance (immutable pattern)
 * - Log sink validation is performed at build time, not during configuration
 * - Memory footprint is minimal until `build()` is called
 *
 * ## Configuration Validation
 * - Log level defaults to `.debug` if not explicitly set
 * - Empty log sinks array is valid (logger will still function)
 * - Duplicate log sinks are allowed (each will receive log messages)
 *
 * - Since: 1.0.0
 * - SeeAlso: `BeaverLogger`, `LogSink`, `LogLevel`
 */
public struct BeaverLoggerBuilder {
    
    // MARK: - Private Properties
    
    /**
     * The minimum log level that will be processed by the built logger.
     *
     * Messages with log levels below this threshold will be filtered out before
     * reaching any log sinks. Defaults to `.debug` to capture all log messages
     * during development.
     *
     * - Note: This setting affects all log sinks uniformly. For sink-specific
     *   filtering, implement the filtering logic within individual log sink
     *   implementations.
     */
    private var logLevel: LogLevel = .debug
    
    /**
     * The collection of log sinks that will receive log messages.
     *
     * Log sinks are output destinations for log messages (console, file, network, etc.).
     * Multiple sinks can be configured to enable simultaneous logging to different
     * destinations. The order of sinks in this array determines the order of
     * message delivery.
     *
     * - Note: An empty array is valid; the logger will still function but won't
     *   output messages anywhere. This can be useful for testing or conditional
     *   logging scenarios.
     */
    private var logSinks: [LogSink] = []

    // MARK: - Initialization
    
    /**
     * Creates a new builder instance with default configuration.
     *
     * The default configuration includes:
     * - Log level set to `.debug` (captures all messages)
     * - Empty log sinks array (no output destinations)
     *
     * ## Usage
     * ```swift
     * let builder = BeaverLoggerBuilder()
     * let logger = builder
     *     .setLogLevel(.info)
     *     .addLogSink(ConsoleLogSink())
     *     .build()
     * ```
     *
     * - Returns: A new builder instance ready for configuration
     */
    public init() {}

    // MARK: - Configuration Methods
    
    /**
     * Sets the minimum log level for the logger being built.
     *
     * This method configures the minimum severity level that log messages must have
     * to be processed by the logger. Messages with lower severity levels will be
     * filtered out early in the logging pipeline, improving performance.
     *
     * ## Log Level Hierarchy
     * From lowest to highest severity:
     * 1. `.debug` - Detailed diagnostic information
     * 2. `.info` - General informational messages
     * 3. `.warning` - Warning conditions
     * 4. `.error` - Error conditions
     * 5. `.critical` - Critical error conditions
     *
     * ## Performance Impact
     * Setting a higher log level (e.g., `.warning`) in production can significantly
     * improve performance by eliminating debug and info message processing overhead.
     *
     * ## Usage Examples
     * ```swift
     * // Development configuration
     * let devLogger = BeaverLoggerBuilder()
     *     .setLogLevel(.debug)
     *     .build()
     *
     * // Production configuration
     * let prodLogger = BeaverLoggerBuilder()
     *     .setLogLevel(.warning)
     *     .build()
     * ```
     *
     * - Parameter logLevel: The minimum log level to process. Messages below this
     *   level will be filtered out.
     * - Returns: A new builder instance with the specified log level configured.
     *   This enables method chaining for fluent configuration.
     *
     * - Note: This method returns a new builder instance rather than modifying
     *   the existing one, maintaining immutability.
     */
    public func setLogLevel(_ logLevel: LogLevel) -> BeaverLoggerBuilder {
        var builder = self
        builder.logLevel = logLevel
        return builder
    }

    /**
     * Adds a log sink to the logger configuration.
     *
     * Log sinks are output destinations that receive and process log messages.
     * Multiple sinks can be added to enable simultaneous logging to different
     * destinations (console, files, network services, etc.).
     *
     * ## Sink Processing Order
     * Log sinks are processed in the order they are added. If sink processing
     * order matters for your use case, add them in the desired sequence.
     *
     * ## Duplicate Sinks
     * The same sink instance can be added multiple times, though this is typically
     * not recommended as it will result in duplicate log output. Consider whether
     * you actually need multiple instances of the same sink type.
     *
     * ## Common Sink Types
     * - `ConsoleLogSink`: Outputs to system console/debug area
     * - `FileLogSink`: Writes to local files with rotation support
     * - Custom sinks: Network logging, database storage, etc.
     *
     * ## Usage Examples
     * ```swift
     * // Single sink
     * let logger = BeaverLoggerBuilder()
     *     .addLogSink(ConsoleLogSink())
     *     .build()
     *
     * // Multiple sinks for redundancy
     * let logger = BeaverLoggerBuilder()
     *     .addLogSink(ConsoleLogSink())
     *     .addLogSink(FileLogSink(fileURL: logFileURL))
     *     .addLogSink(RemoteLogSink(endpoint: analyticsEndpoint))
     *     .build()
     *
     * // Conditional sink addition
     * var builder = BeaverLoggerBuilder()
     * if isDebugMode {
     *     builder = builder.addLogSink(ConsoleLogSink())
     * }
     * if enableFileLogging {
     *     builder = builder.addLogSink(FileLogSink(fileURL: logFileURL))
     * }
     * let logger = builder.build()
     * ```
     *
     * - Parameter logSink: The log sink instance to add to the configuration.
     *   The sink must conform to the `LogSink` protocol.
     * - Returns: A new builder instance with the specified log sink added to
     *   the configuration. This enables method chaining for fluent configuration.
     *
     * - Note: This method returns a new builder instance rather than modifying
     *   the existing one, maintaining immutability.
     * - SeeAlso: `LogSink` protocol for implementing custom sinks
     */
    public func addLogSink(_ logSink: LogSink) -> BeaverLoggerBuilder {
        var builder = self
        builder.logSinks.append(logSink)
        return builder
    }

    // MARK: - Build Method
    
    /**
     * Creates and returns a configured `BeaverLogger` instance.
     *
     * This method finalizes the configuration process and constructs a new
     * `BeaverLogger` instance with all the specified settings. Once built,
     * the logger is ready for immediate use and is thread-safe.
     *
     * ## Configuration Applied
     * The built logger will have:
     * - The configured minimum log level (or `.debug` if not set)
     * - All added log sinks in the order they were added
     * - Thread-safe message processing capabilities
     * - Optimized filtering based on the log level
     *
     * ## Performance Characteristics
     * - Logger construction is lightweight and fast
     * - Log sinks are stored by reference (no deep copying)
     * - Internal structures are optimized for concurrent access
     * - Message filtering is optimized based on the configured log level
     *
     * ## Thread Safety
     * The returned logger instance is fully thread-safe and can be used
     * concurrently from multiple threads without additional synchronization.
     *
     * ## Usage Examples
     * ```swift
     * // Simple logger
     * let logger = BeaverLoggerBuilder()
     *     .setLogLevel(.info)
     *     .addLogSink(ConsoleLogSink())
     *     .build()
     *
     * // Store for reuse
     * let sharedLogger = BeaverLoggerBuilder()
     *     .setLogLevel(.warning)
     *     .addLogSink(FileLogSink(fileURL: logFileURL))
     *     .build()
     *
     * // Immediate use
     * BeaverLoggerBuilder()
     *     .addLogSink(ConsoleLogSink())
     *     .build()
     *     .info("Application started", tag: AppTags.lifecycle)
     * ```
     *
     * ## Error Handling
     * This method does not throw errors. Invalid configurations (like empty
     * sink arrays) are handled gracefully:
     * - Empty sinks: Logger functions but doesn't output messages
     * - Invalid log levels: Not possible due to enum constraints
     *
     * - Returns: A fully configured, thread-safe `BeaverLogger` instance ready
     *   for use. The logger maintains references to the configured log sinks
     *   and applies the specified log level filtering.
     *
     * - Note: After calling this method, the builder can be reused to create
     *   additional logger instances with the same configuration, or further
     *   configured for different loggers.
     * - SeeAlso: `BeaverLogger` for usage documentation of the built logger
     */
    public func build() -> BeaverLogger {
        return BeaverLogger(logLevel: logLevel, logSinks: logSinks)
    }
}
