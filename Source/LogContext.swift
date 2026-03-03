import Foundation

/// Source-code context associated with a log entry.
///
/// `LogContext` captures information about the location in the source code
/// from which a log message originates. It is used to enrich log entries
/// with metadata that is valuable for debugging, tracing, and diagnostics.
///
/// A `LogContext` is typically created automatically by the logging system
/// using compiler-provided literals (`#fileID`, `#function`, `#line`) and
/// passed to `LogSink` implementations alongside the log message.
///
/// - Note:
///   `LogContext` is intentionally lightweight and immutable. It contains
///   only metadata that is cheap to capture at the call site.
public struct LogContext: Sendable {
    /// The file from which the log entry was emitted.
    ///
    /// This value typically corresponds to the compiler-provided `#fileID` literal and uniquely identifies the source file within the module.
    public let file: StaticString
    /// The function or method from which the log entry was emitted.
    ///
    /// This value typically corresponds to the compiler-provided `#function` literal.
    public let function: StaticString
    /// The line number from which the log entry was emitted.
    ///
    /// This value typically corresponds to the compiler-provided `#line` literal.
    public let line: UInt

    /// Creates a new source-code context for a log entry.
    ///
    /// - Parameters:
    ///   - file: The source file in which the log call occurred.
    ///   - function: The function or method in which the log call occurred.
    ///   - line: The line number at which the log call occurred.
    public init(
        file: StaticString,
        function: StaticString,
        line: UInt
    ) {
        self.file = file
        self.function = function
        self.line = line
    }
}
