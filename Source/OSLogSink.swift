import OSLog

/// A `LogSink` implementation that forwards log entries to Apple's unified logging system (`os.Logger`).
///
/// `OSLogSink` acts as a thin adapter between the logging framework and `os.Logger`.
/// It is responsible for:
/// - Translating log metadata into an `os.Logger` subsystem and category
/// - Mapping `LogLevel` values to the appropriate OS log severity
/// - Emitting formatted log messages with public visibility
///
/// Formatting logic is delegated to `OSLogFormatter`, keeping this sink
/// lightweight, stateless, and easy to reason about.
///
/// - Important:
///   `OSLogSink` does not perform filtering or configuration logic.
///   Log-level filtering and sink composition are handled by higher-level components such as `BeaverLogger` and `LoggerFacade`.
///
/// - Note:
///   Instances of `OSLogSink` are cheap to create and safe to reuse.
public struct OSLogSink: LogSink {
    private let formatter = OSLogFormatter()
    /// Creates a new OSLog sink.
    ///
    /// The sink is stateless and does not require any configuration.
    public init() {}

    /// Writes a log entry to the unified logging system.
    ///
    /// This method formats the log entry using `OSLogFormatter`, constructs
    /// an `os.Logger` using the derived subsystem and category, and emits
    /// the message using the appropriate OS log level.
    ///
    /// - Parameters:
    ///   - logLevel: The severity of the log entry.
    ///   - logTag: The tag identifying the logical source of the log entry.
    ///   - message: The log message to emit.
    ///   - context: Source-code context associated with the log entry.
    public func writeLog(
        logLevel: LogLevel,
        logTag: LogTag,
        message: LogMessage,
        context: LogContext
    ) {
        let output = formatter.format(level: logLevel, tag: logTag, message: message, context: context)
        let logger = Logger(
            subsystem: output.subsystem,
            category: output.category
        )
        
        switch logLevel {
        case .debug:
            logger.debug("\(output.message, privacy: .public)")
        case .info:
            logger.info("\(output.message, privacy: .public)")
        case .warning:
            logger.fault("\(output.message, privacy: .public)")
        case .error:
            logger.error("\(output.message, privacy: .public)")
        }
    }
}

struct OSLogFormatter {
    struct Output {
        let subsystem: String
        let category: String
        let message: String
    }
    func format(
        level: LogLevel,
        tag: LogTag,
        message: LogMessage,
        context: LogContext
    ) -> Output {
        let subsystem = tag.subsystem
        let category = String(describing: tag.identifier)

        let prefix = formattedPrefix(level: level, tag: tag, context: context)
        let message = "\(prefix): \(message.value)"

        return Output(
            subsystem: subsystem,
            category: category,
            message: message
        )
    }

    private func formattedPrefix(
        level: LogLevel,
        tag: LogTag,
        context: LogContext
    ) -> String {
        let filename = fileName(from: context.file)
        return "[\(level.name)] \(filename).\(context.function).\(context.line)"
    }

    private func fileName(from file: StaticString) -> String {
        URL(fileURLWithPath: String(describing: file))
            .lastPathComponent
    }
}
