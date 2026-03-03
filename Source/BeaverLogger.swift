public protocol LoggerProtocol: LogSink {
    func debug(_ message: LogMessage, tag: LogTag, file: StaticString, function: StaticString, line: UInt)
    func info(_ message: LogMessage, tag: LogTag, file: StaticString, function: StaticString, line: UInt)
    func warning(_ message: LogMessage, tag: LogTag, file: StaticString, function: StaticString, line: UInt)
    func error(_ message: LogMessage, tag: LogTag, file: StaticString, function: StaticString, line: UInt)
}

/// Central facade for the application's logging system.
///
/// `BeaverLogger` coordinates logging across multiple `LogSink` implementations and provides a single, concurrency-safe entry point
/// for emitting log messages.
///
/// This type is implemented as an `actor` to safely manage shared configuration and mutable state across concurrent callers. All logging
/// and configuration operations go through this actor.
///
/// Usage:
/// ```swift
/// // Configure once during application startup
/// await BeaverLogger.shared.configure(
///     .init(
///         minimumLevel: .info,
///         sinks: [OSLogSink(), MyCustomSink()]
///     )
/// )
///
/// // Emit logs from anywhere in the app
/// await BeaverLogger.shared.log(.info, tag: LogTags.lifecycle, "App launched")
/// ```
public actor BeaverLogger {
    /// Shared global logger instance.
    ///
    /// This is the primary entry point for logging in the application.
    /// Callers are expected to use `BeaverLogger.shared` rather than
    /// creating additional instances.
    public static let shared = BeaverLogger()

    /// The underlying logger implementation used to emit log messages.
    ///
    /// This value is configured via ``configure(_:)`` and typically wraps one or more `LogSink` instances (for example, an `OSLogSink`
    /// plus additional sinks provided by the application).
    public private(set) var logger: LoggerProtocol = LoggerFacade(
        sink: OSLogSink(),
        minimumLevel: .debug
    )

    private init() {}

    // MARK: - Configuration

    /// Configures the logging system.
    ///
    /// This method replaces the current logger configuration with the provided set of sinks and minimum log level. It is intended to be
    /// called once during application startup (for example, in `AppDelegate` or the main SwiftUI `App` type), before any log messages are emitted.
    ///
    /// - Parameter configuration: The logging configuration, including minimum log level and the list of sinks that should receive log messages.
    public func configure(_ configuration: Configuration) {
        let multiplex = LogSinks(configuration.sinks)
        self.logger = LoggerFacade(
            sink: multiplex,
            minimumLevel: configuration.minimumLevel
        )
    }

    // MARK: - Logging

    /// Emits a log message with the given level and tag.
    ///
    /// This method is the primary low-level entry point for logging. It
    /// constructs a `LogContext` from the call site and forwards the
    /// message, metadata, and context to the configured `LoggerProtocol`.
    ///
    /// - Parameters:
    ///   - level: The severity of the log message.
    ///   - tag: The tag identifying the logical source or category of
    ///     the log entry.
    ///   - message: The log message to emit.
    ///   - file: The source file from which the log was issued. Defaults
    ///     to the caller's file via `#fileID`.
    ///   - function: The function from which the log was issued. Defaults
    ///     to the caller's function via `#function`.
    ///   - line: The line number from which the log was issued. Defaults
    ///     to the caller's line via `#line`.
    public func log(
        _ level: LogLevel,
        tag: LogTag,
        _ message: LogMessage,
        file: StaticString = #fileID,
        function: StaticString = #function,
        line: UInt = #line
    ) {
        let context = LogContext(file: file, function: function, line: line)
        logger.writeLog(
            logLevel: level,
            logTag: tag,
            message: message,
            context: context
        )
    }

    /// Configuration values for `BeaverLogger`.
    ///
    /// A `Configuration` specifies the minimum log level and the set of
    /// sinks that should receive log messages. It is used to configure
    /// the global logger via ``BeaverLogger/configure(_:)``.
    public struct Configuration {
        /// The minimum log level that will be emitted.
        ///
        /// Log messages below this level are ignored. This allows the
        /// application to reduce log volume in production while keeping
        /// more verbose logging in development or testing environments.
        public let minimumLevel: LogLevel
        /// The collection of sinks that will receive log messages.
        ///
        /// Each sink is responsible for handling log entries in its own
        /// way (for example, sending them to the console, a file, or a
        /// remote logging backend). The sinks are typically wrapped by
        /// a multiplexing sink (`LogSinks`) so that all configured sinks
        /// receive each log entry.
        public let sinks: [any LogSink]

        /// Creates a new logging configuration.
        ///
        /// - Parameters:
        ///   - minimumLevel: The minimum log level to emit. Defaults to `.debug`.
        ///   - sinks: The list of sinks that should receive log messages. Defaults to a single `OSLogSink`.
        public init(
            minimumLevel: LogLevel = .debug,
            sinks: [any LogSink] = [OSLogSink()]
        ) {
            self.minimumLevel = minimumLevel
            self.sinks = sinks
        }
    }
}
