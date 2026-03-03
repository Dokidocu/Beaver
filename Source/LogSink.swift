import Foundation

/// A destination for log messages.
///
/// `LogSink` represents a single output target in the logging system,
/// such as the console, a file, or a remote logging service.
/// Implementations are responsible for consuming fully constructed
/// `LogMessage` values together with their associated metadata.
///
/// Conforming types **must be thread-safe** and suitable for use from
/// concurrent contexts, as log calls may occur from multiple threads
/// or actors simultaneously.
///
/// - Important:
///   Implementations of `writeLog` should be **fast and non-blocking**.
///   If a sink performs expensive work (e.g. disk IO or networking),
///   it should buffer or dispatch work asynchronously.
///
/// - Note:
///   `LogSink` receives an already-formatted `LogMessage`. Formatting,
///   interpolation, and message construction are intentionally performed
///   before invoking the sink to keep sinks simple and predictable.
public protocol LogSink: Sendable {
    /// Writes a log entry to the sink.
    ///
    /// This method is the core entry point for all log events. It is
    /// invoked after the log message has been fully constructed and
    /// enriched with contextual information.
    ///
    /// - Parameters:
    ///   - logLevel: The severity level of the log entry.
    ///   - logTag: A tag identifying the logical source or feature
    ///     producing the log (for example, networking or authentication).
    ///   - message: The fully formatted log message.
    ///   - context: Source-code context associated with the log call, including file, function, and line number.
    func writeLog(
        logLevel: LogLevel,
        logTag: LogTag,
        message: LogMessage,
        context: LogContext
    )
}

public extension LogSink {
    /// Writes a log entry to the sink with automatically captured
    /// source-code context.
    ///
    /// This convenience overload captures the calling file, function,
    /// and line number using compiler-provided literals and constructs
    /// a `LogContext` automatically.
    ///
    /// Callers typically use this method rather than constructing a
    /// `LogContext` manually.
    ///
    /// - Parameters:
    ///   - logLevel: The severity level of the log entry.
    ///   - logTag: A tag identifying the logical source or feature
    ///     producing the log.
    ///   - message: The fully formatted log message.
    ///   - file: The file from which the log is emitted. Defaults to the caller’s source file.
    ///   - function: The function from which the log is emitted. Defaults to the caller’s function name.
    ///   - line: The line number from which the log is emitted. Defaults to the caller’s line number.
    func writeLog(
        logLevel: LogLevel,
        logTag: LogTag,
        message: LogMessage,
        file: StaticString = #fileID,
        function: StaticString = #function,
        line: UInt = #line
    ) {
        let context = LogContext(file: file, function: function, line: line)
        writeLog(
            logLevel: logLevel,
            logTag: logTag,
            message: message,
            context: context
        )
    }
}
