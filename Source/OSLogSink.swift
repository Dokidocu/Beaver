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
///   Log-level filtering and sink composition are handled by higher-level components such as ``Log`` and `LoggerFacade`.
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
        let logger = LoggerCache.logger(subsystem: output.subsystem, category: output.category)

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

// MARK: - Logger cache

/// Caches `os.Logger` instances keyed by subsystem + category.
///
/// `os.Logger` should be created once per subsystem/category pair and reused.
/// This cache avoids repeated allocations on hot logging paths.
private enum LoggerCache {
    private static let lock = NSLock()
    private static var cache: [String: Logger] = [:]

    static func logger(subsystem: String, category: String) -> Logger {
        let key = "\(subsystem)/\(category)"
        lock.lock()
        defer { lock.unlock() }
        if let cached = cache[key] { return cached }
        let logger = Logger(subsystem: subsystem, category: category)
        cache[key] = logger
        return logger
    }
}

// MARK: - Formatter

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
        let prefix = formattedPrefix(level: level, context: context)
        return Output(
            subsystem: tag.subsystem,
            category: tag.identifier,
            message: "\(prefix): \(message.value)"
        )
    }

    private func formattedPrefix(level: LogLevel, context: LogContext) -> String {
        let filename = fileName(from: context.file)
        return "[\(level.name)] \(filename).\(context.function).\(context.line)"
    }

    private func fileName(from file: StaticString) -> String {
        let str = String(describing: file)
        return str.split(separator: "/").last.map(String.init) ?? str
    }
}
