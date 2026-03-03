import OSLog

/// Represents the severity of a log entry.
///
/// `LogLevel` defines the relative importance of a log message, from
/// verbose debugging information to error conditions. Higher raw values
/// indicate more severe log levels and can be used for filtering and
/// routing log output.
///
/// The order is:
/// - `debug` (least severe)
/// - `info`
/// - `warning`
/// - `error` (most severe)
public enum LogLevel: Int, CaseIterable, Sendable, CustomStringConvertible, Comparable {
    /// Detailed information intended for debugging and development-time analysis (least severe).
    case debug = 0
    /// General informational messages that describe the normal flow of the application.
    case info = 1
    /// Potentially harmful situations that do not stop execution but may require attention.
    case warning = 2
    /// Error events that indicate a failure or a condition that is likely to affect application behavior (most severe).
    case error = 3

    // MARK: - Public APIs

    /// Uppercased name of the log level, suitable for formatted output.
    ///
    /// Examples:
    /// - `.debug` → `"DEBUG"`
    /// - `.info` → `"INFO"`
    /// - `.warning` → `"WARNING"`
    /// - `.error` → `"ERROR"`
    public var name: String {
        switch self {
        case .debug: return "DEBUG"
        case .info: return "INFO"
        case .warning: return "WARNING"
        case .error: return "ERROR"
        }
    }

    /// Compares two log levels by severity.
    ///
    /// This operator can be used to check whether a given level is at
    /// least as severe as another one, for example:
    ///
    /// ```swift
    /// if logLevel >= .info {
    ///     // log or handle the message
    /// }
    /// ```
    public static func < (lhs: LogLevel, rhs: LogLevel) -> Bool {
        lhs.rawValue < rhs.rawValue
    }

    /// Textual representation of the log level.
    ///
    /// This returns the same value as ``LogLevel/name`` and is used when
    /// converting the level to a `String`, for example via string
    /// interpolation or `String(describing:)`.
    public var description: String { name }

    // MARK: - Internal

    var osLogType: OSLogType {
        switch self {
        case .debug: return .debug
        case .info: return .info
        case .warning: return .fault
        case .error: return .error
        }
    }
}
