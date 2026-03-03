import Foundation

/// Thread-safe container for the active ``LoggerFacade``.
///
/// `LoggerState` allows ``Log`` to expose `nonisolated` logging
/// methods by storing the current facade behind an `NSLock`. Reads and
/// writes are O(1) and contention is expected to be negligible — configure
/// is called once; log calls only need a single lock-protected load.
final class LoggerState: @unchecked Sendable {
    private var facade: LoggerFacade
    private let lock = NSLock()

    init(_ facade: LoggerFacade) {
        self.facade = facade
    }

    /// Forwards a log entry to the current facade without holding the lock
    /// during the actual write (the facade itself is immutable).
    func writeLog(
        logLevel: LogLevel,
        logTag: LogTag,
        message: LogMessage,
        context: LogContext
    ) {
        let current = lock.withLock { facade }
        current.writeLog(logLevel: logLevel, logTag: logTag, message: message, context: context)
    }

    /// Atomically replaces the active facade (called by `configure`).
    func update(_ facade: LoggerFacade) {
        lock.withLock { self.facade = facade }
    }
}
