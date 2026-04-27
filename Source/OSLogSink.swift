import OSLog

/// Controls how source-code location is rendered in formatted log output.
public enum LogSourceFormat: Sendable {
    /// Includes file name, function, and line number.
    case full
    /// Includes file name and line number.
    case compact
    /// Omits source-code location from the formatted message.
    case none
}

/// Controls the default privacy of interpolated values bridged to Apple's unified logging system.
///
/// Literal text in the formatted message always remains visible. This mode controls
/// only interpolated values that do not carry an explicit `\(private: ...)` or
/// `\(public: ...)` annotation in ``LogMessage``.
public enum OSLogPrivacyMode: Sendable, Equatable {
    /// Redacts unannotated interpolated values as `<private>`.
    case `private`
    /// Exposes unannotated interpolated values in unified logging output.
    case `public`
}

/// A `LogSink` implementation that forwards log entries to Apple's unified logging system (`os.Logger`).
///
/// `OSLogSink` acts as a thin adapter between the logging framework and `os.Logger`.
/// It is responsible for:
/// - Translating log metadata into an `os.Logger` subsystem and category
/// - Mapping `LogLevel` values to the appropriate OS log severity
/// - Redacting interpolated values privately by default unless they are explicitly public
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
    private let formatter: OSLogFormatter
    private let privacy: OSLogPrivacyMode
    private let emit: @Sendable (Logger, LogLevel, String) -> Void

    /// Creates a new OSLog sink.
    ///
    /// The default formatted output includes the log level, tag, compact source location,
    /// and message text.
    ///
    /// - Parameters:
    ///   - sourceFormat: Controls how source-code location appears in the formatted message.
    ///   - privacy: Controls the default privacy for unannotated interpolated values.
    ///     Defaults to `.private`.
    public init(
        sourceFormat: LogSourceFormat = .compact,
        privacy: OSLogPrivacyMode = .private
    ) {
        self.init(
            sourceFormat: sourceFormat,
            privacy: privacy,
            emit: Self.defaultEmit
        )
    }

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
        let logger = LoggerCache.shared.logger(subsystem: output.subsystem, category: output.category)
        let renderedMessage = output.redactedMessage(defaultPrivacy: privacy)
        emit(logger, logLevel, renderedMessage)
    }

    init(
        sourceFormat: LogSourceFormat = .compact,
        privacy: OSLogPrivacyMode = .private,
        emit: @escaping @Sendable (Logger, LogLevel, String) -> Void
    ) {
        formatter = OSLogFormatter(sourceFormat: sourceFormat)
        self.privacy = privacy
        self.emit = emit
    }

    private static let defaultEmit: @Sendable (Logger, LogLevel, String) -> Void = {
        logger,
        logLevel,
        message in
        switch logLevel {
        case .debug:
            logger.debug("\(message, privacy: .public)")
        case .info:
            logger.info("\(message, privacy: .public)")
        case .warning:
            logger.fault("\(message, privacy: .public)")
        case .error:
            logger.error("\(message, privacy: .public)")
        }
    }
}

// MARK: - Logger cache

/// Caches `os.Logger` instances keyed by subsystem + category.
///
/// `os.Logger` should be created once per subsystem/category pair and reused.
/// This cache avoids repeated allocations on hot logging paths.
///
/// `@unchecked Sendable` is safe here: all access to `cache` is serialised through `lock`.
private final class LoggerCache: @unchecked Sendable {
    static let shared = LoggerCache()

    private var cache: [String: Logger] = [:]
    private let lock = NSLock()

    private init() {}

    func logger(subsystem: String, category: String) -> Logger {
        let key = "\(subsystem)/\(category)"
        return lock.withLock {
            if let cached = cache[key] { return cached }
            let logger = Logger(subsystem: subsystem, category: category)
            cache[key] = logger
            return logger
        }
    }
}

// MARK: - Formatter

struct OSLogFormatter {
    let sourceFormat: LogSourceFormat

    struct Output {
        let subsystem: String
        let category: String
        let prefix: String
        let source: String?
        let message: LogMessage

        func redactedMessage(defaultPrivacy: OSLogPrivacyMode) -> String {
            let body = message.renderedValue(
                defaultPrivacy: defaultPrivacy == .private ? .private : .public
            )
            if let source {
                return "\(prefix) \(source): \(body)"
            } else {
                return "\(prefix) \(body)"
            }
        }
    }

    func format(
        level: LogLevel,
        tag: LogTag,
        message: LogMessage,
        context: LogContext
    ) -> Output {
        let prefix = formattedPrefix(level: level, tag: tag)
        return Output(
            subsystem: tag.subsystem,
            category: tag.identifier,
            prefix: prefix,
            source: formattedSource(context: context),
            message: message
        )
    }

    private func formattedPrefix(level: LogLevel, tag: LogTag) -> String {
        "[\(level.name)] [\(displayTag(from: tag))]"
    }

    private func formattedSource(context: LogContext) -> String? {
        let filename = fileName(from: context.file)
        switch sourceFormat {
        case .full:
            return "\(filename).\(context.function).\(context.line)"
        case .compact:
            return "\(filename):\(context.line)"
        case .none:
            return nil
        }
    }

    private func displayTag(from tag: LogTag) -> String {
        let name = String(describing: tag.name)
        return name.isEmpty ? tag.identifier : name
    }

    private func fileName(from file: StaticString) -> String {
        let str = String(describing: file)
        return str.split(separator: "/").last.map(String.init) ?? str
    }
}
