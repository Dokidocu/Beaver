import Foundation

/// Identifies a logical source or category for log messages.
///
/// `LogTag` provides lightweight, compile-time metadata that is attached to each log entry in order to group, filter, and format logs consistently.
/// Tags are typically defined as static constants and reused across the application.
///
/// Most properties use `StaticString` to ensure:
/// - Zero heap allocation
/// - Stable values known at compile time
/// - Efficient use in high-frequency logging paths
///
/// A `LogTag` usually represents a feature area or subsystem, such as networking, authentication, or persistence.
public struct LogTag: Sendable, Equatable, Hashable {
    /// The subsystem associated with this log tag.
    ///
    /// This value is commonly mapped to the `subsystem` parameter of
    /// `os.Logger` and is used to group logs at a high level.
    ///
    /// Typical values include the application bundle identifier or a
    /// module-specific identifier, for example:
    /// - `"com.example.app"`
    /// - `"com.example.app.network"`
    public let subsystem: String
    /// A short prefix used to visually distinguish log entries.
    ///
    /// The prefix is intended for human-readable log output and may contain
    /// abbreviations, symbols, or emojis, such as:
    /// - `"NET"`
    /// - `"AUTH"`
    /// - `"🔐"`
    ///
    /// It is commonly rendered before the tag name in formatted logs.
    public let prefix: StaticString
    /// The logical name of the log tag.
    ///
    /// This name identifies the category of the log entry and is suitable
    /// for filtering, grouping, and structured log output.
    ///
    /// Examples include:
    /// - `"Network"`
    /// - `"Auth"`
    /// - `"Database"`
    public let name: StaticString

    /// Creates a new log tag with compile-time constant values.
    ///
    /// - Parameters:
    ///   - subsystem: The subsystem associated with this tag.
    ///   - prefix: A short prefix used for formatted log output.
    ///   - name: The logical name of the tag.
    ///
    /// - Note:
    ///   All parameters are `StaticString` to encourage the use of
    ///   compile-time constants and avoid runtime allocations.
    public init(
        subsystem: StaticString,
        prefix: StaticString,
        name: StaticString
    ) {
        self.subsystem = String(describing: subsystem)
        self.prefix = prefix
        self.name = name
    }

    public init(
        subsystem: String,
        prefix: StaticString,
        name: StaticString
    ) {
        self.subsystem = subsystem
        self.prefix = prefix
        self.name = name
    }

    public static func == (lhs: LogTag, rhs: LogTag) -> Bool {
        lhs.subsystem == rhs.subsystem
            && String(describing: lhs.prefix) == String(describing: rhs.prefix)
            && String(describing: lhs.name) == String(describing: rhs.name)
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(subsystem)
        hasher.combine(String(describing: prefix))
        hasher.combine(String(describing: name))
    }

    /// Combined identifier commonly used in formatted log output.
    ///
    /// If a prefix is present, this combines the prefix and name:
    /// - `"NET Network"`
    /// - `"🔐 Auth"`
    ///
    /// If the prefix is empty, only the name is used.
    public var identifier: String {
        if String(describing: prefix).isEmpty {
            return String(describing: name)
        } else {
            return "\(prefix) \(name)"
        }
    }
}
