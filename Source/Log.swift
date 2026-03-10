/// Central facade for the application's logging system.
///
/// `Log` coordinates logging across multiple ``LogSink`` implementations and provides a
/// single, concurrency-safe entry point for emitting log messages.
///
/// The actor manages configuration state (via ``configure(_:)``), while all logging methods are
/// `nonisolated` — they never suspend and can be called from any thread, actor, or `@MainActor`
/// context with no `await` required.
///
/// ## Quick start
///
/// ```swift
/// // Configure once during app startup (typically in App.init or AppDelegate)
/// await Log.configure(.init(minimumLevel: .info, sinks: [OSLogSink()]))
///
/// // Log from anywhere — no await, no boilerplate
/// Log.info("App launched", tag: LogTags.lifecycle)
/// Log.error("Request failed: \(error)", tag: LogTags.network)
/// ```
public actor Log {
    // MARK: - Shared instance

    /// Shared global logger instance.
    public static let shared = Log()

    // MARK: - Internal state

    /// Lock-protected container for the active logging pipeline.
    ///
    /// Stored as a `nonisolated let` so that `nonisolated` logging methods can access it
    /// without hopping onto the actor.
    private let _state: LoggerState

    private init() {
        _state = LoggerState(LoggerFacade(sink: OSLogSink(), minimumLevel: .debug))
    }

    // MARK: - Configuration

    /// Configures the shared logger.
    ///
    /// Call this once at startup. All subsequent log calls pick up the new configuration
    /// atomically. This method is actor-isolated and therefore `async`, but it is called
    /// infrequently enough that the single suspension is not a concern.
    ///
    /// - Parameter configuration: The desired logging configuration.
    public func configure(_ configuration: Configuration) {
        _state.update(LoggerFacade(
            sink: LogSinks(configuration.sinks),
            minimumLevel: configuration.minimumLevel
        ))
    }

    /// Convenience wrapper that configures the shared logger without needing a reference.
    ///
    /// ```swift
    /// await Log.configure(.init(minimumLevel: .info, sinks: [OSLogSink()]))
    /// ```
    public static func configure(_ configuration: Configuration) async {
        await shared.configure(configuration)
    }

    // MARK: - Core logging (nonisolated — no await needed)

    /// Emits a log message with the given level and tag.
    ///
    /// This method is `nonisolated` and therefore synchronous. It can be called from any
    /// context — `@MainActor`, a background task, a completion handler — without `await`.
    ///
    /// - Parameters:
    ///   - level: The severity of the log message.
    ///   - tag: The tag identifying the logical source or category of the log entry.
    ///   - message: The log message to emit.
    ///   - file: The source file. Defaults to the caller's file via `#fileID`.
    ///   - function: The function. Defaults to the caller's function via `#function`.
    ///   - line: The line number. Defaults to the caller's line via `#line`.
    public nonisolated func log(
        _ level: LogLevel,
        tag: LogTag,
        _ message: LogMessage,
        file: StaticString = #fileID,
        function: StaticString = #function,
        line: UInt = #line
    ) {
        _state.writeLog(
            logLevel: level,
            logTag: tag,
            message: message,
            context: LogContext(file: file, function: function, line: line)
        )
    }

    // MARK: - Instance convenience methods

    /// Logs a debug-level message.
    public nonisolated func debug(
        _ message: LogMessage,
        tag: LogTag = LogTags.general,
        file: StaticString = #fileID,
        function: StaticString = #function,
        line: UInt = #line
    ) {
        log(.debug, tag: tag, message, file: file, function: function, line: line)
    }

    /// Logs an info-level message.
    public nonisolated func info(
        _ message: LogMessage,
        tag: LogTag = LogTags.general,
        file: StaticString = #fileID,
        function: StaticString = #function,
        line: UInt = #line
    ) {
        log(.info, tag: tag, message, file: file, function: function, line: line)
    }

    /// Logs a warning-level message.
    public nonisolated func warning(
        _ message: LogMessage,
        tag: LogTag = LogTags.general,
        file: StaticString = #fileID,
        function: StaticString = #function,
        line: UInt = #line
    ) {
        log(.warning, tag: tag, message, file: file, function: function, line: line)
    }

    /// Logs an error-level message.
    public nonisolated func error(
        _ message: LogMessage,
        tag: LogTag = LogTags.general,
        file: StaticString = #fileID,
        function: StaticString = #function,
        line: UInt = #line
    ) {
        log(.error, tag: tag, message, file: file, function: function, line: line)
    }

    // MARK: - Static convenience methods

    /// Logs a debug-level message via the shared logger.
    public static func debug(
        _ message: LogMessage,
        tag: LogTag = LogTags.general,
        file: StaticString = #fileID,
        function: StaticString = #function,
        line: UInt = #line
    ) {
        shared.debug(message, tag: tag, file: file, function: function, line: line)
    }

    /// Logs an info-level message via the shared logger.
    public static func info(
        _ message: LogMessage,
        tag: LogTag = LogTags.general,
        file: StaticString = #fileID,
        function: StaticString = #function,
        line: UInt = #line
    ) {
        shared.info(message, tag: tag, file: file, function: function, line: line)
    }

    /// Logs a warning-level message via the shared logger.
    public static func warning(
        _ message: LogMessage,
        tag: LogTag = LogTags.general,
        file: StaticString = #fileID,
        function: StaticString = #function,
        line: UInt = #line
    ) {
        shared.warning(message, tag: tag, file: file, function: function, line: line)
    }

    /// Logs an error-level message via the shared logger.
    public static func error(
        _ message: LogMessage,
        tag: LogTag = LogTags.general,
        file: StaticString = #fileID,
        function: StaticString = #function,
        line: UInt = #line
    ) {
        shared.error(message, tag: tag, file: file, function: function, line: line)
    }

    // MARK: - Configuration

    /// Configuration values for ``Log``.
    public struct Configuration: Sendable {
        /// The minimum log level that will be emitted.
        ///
        /// Messages below this level are filtered out before reaching any sink.
        public let minimumLevel: LogLevel

        /// The collection of sinks that will receive log messages.
        ///
        /// Each sink handles log entries in its own way (console, file, remote service, etc.).
        /// When multiple sinks are provided they all receive every message that passes the
        /// minimum level filter.
        public let sinks: [any LogSink]

        /// Creates a new logging configuration.
        ///
        /// - Parameters:
        ///   - minimumLevel: The minimum log level to emit. Defaults to `.debug`.
        ///   - sinks: The sinks that should receive log messages. Defaults to a single `OSLogSink`.
        public init(
            minimumLevel: LogLevel = .debug,
            sinks: [any LogSink] = [OSLogSink()]
        ) {
            self.minimumLevel = minimumLevel
            self.sinks = sinks
        }
    }
}
