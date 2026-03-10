import Foundation
import Beaver

/// A `LogSink` conformance that records log entries using only the public Beaver API.
///
/// Used in public-API tests to verify end-to-end logging behavior without `@testable` access.
/// The fact that this type compiles without `@testable import Beaver` is itself a contract test:
/// if `LogSink`, `LogLevel`, `LogTag`, `LogMessage`, or `LogContext` were ever made internal,
/// compilation would fail here.
///
/// Thread-safe: concurrent `writeLog` calls are serialised through an `NSLock`.
final class PublicSink: @unchecked Sendable, LogSink {
    struct Entry {
        let level: LogLevel
        let tag: LogTag
        let message: String
        let file: StaticString
        let function: StaticString
        let line: UInt
    }

    private var _entries: [Entry] = []
    private let lock = NSLock()

    var entries: [Entry] {
        lock.withLock { _entries }
    }

    func writeLog(
        logLevel: LogLevel,
        logTag: LogTag,
        message: LogMessage,
        context: LogContext
    ) {
        lock.withLock {
            _entries.append(Entry(
                level: logLevel,
                tag: logTag,
                message: message.value,
                file: context.file,
                function: context.function,
                line: context.line
            ))
        }
    }
}
