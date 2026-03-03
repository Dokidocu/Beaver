import Foundation
@testable import Beaver

final class TestSink: @unchecked Sendable, LogSink {
    struct Entry {
        let level: LogLevel
        let tag: LogTag
        let message: String
        let file: StaticString
        let function: StaticString
        let line: UInt
    }

    private(set) var entriesStorage: [Entry] = []
    private let lock = NSLock()

    var entries: [Entry] {
        lock.withLock { entriesStorage }
    }

    func writeLog(
        logLevel: LogLevel,
        logTag: LogTag,
        message: LogMessage,
        context: LogContext
    ) {
        let entry = Entry(
            level: logLevel,
            tag: logTag,
            message: message.value,
            file: context.file,
            function: context.function,
            line: context.line
        )
        lock.withLock { entriesStorage.append(entry) }
    }
}
