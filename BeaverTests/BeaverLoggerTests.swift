import XCTest
@testable import Beaver

final class BeaverLoggerTests: XCTestCase {
    func testConfigureReplacesUnderlyingLoggerWithProvidedSinks() async throws {
        let sink = TestSink()
        let config = BeaverLogger.Configuration(
            minimumLevel: .debug,
            sinks: [sink]
        )

        await BeaverLogger.shared.configure(config)

        let tag = LogTag(
            subsystem: "com.example.app",
            prefix: "TEST",
            name: "Test"
        )
        let message: LogMessage = "Hello"

        await BeaverLogger.shared.log(
            .info,
            tag: tag,
            message
        )

        XCTAssertEqual(sink.entries.count, 1)
        let entry = try XCTUnwrap(sink.entries.first)

        XCTAssertEqual(entry.level, .info)
        XCTAssertEqual(entry.tag.subsystem, "com.example.app")
        XCTAssertEqual(String(describing: entry.tag.name), "Test")
        XCTAssertEqual(entry.message, "Hello")
    }

    func testMinimumLevelIsRespected() async throws {
        let sink = TestSink()
        let config = BeaverLogger.Configuration(
            minimumLevel: .info,
            sinks: [sink]
        )

        await BeaverLogger.shared.configure(config)

        let tag = LogTag(
            subsystem: "com.example.app",
            prefix: "TEST",
            name: "Test"
        )

        let debugMessage: LogMessage = "Debug message"
        let infoMessage: LogMessage = "Info message"

        // This should be filtered out by the configured minimumLevel
        await BeaverLogger.shared.log(.debug, tag: tag, debugMessage)

        // This should be logged
        await BeaverLogger.shared.log(.info, tag: tag, infoMessage)

        XCTAssertEqual(sink.entries.count, 1)
        let entry = try XCTUnwrap(sink.entries.first)
        XCTAssertEqual(entry.level, .info)
        XCTAssertEqual(entry.message, "Info message")
    }

    func testContextInformationIsPassedThrough() async throws {
        let sink = TestSink()
        let config = BeaverLogger.Configuration(
            minimumLevel: .debug,
            sinks: [sink]
        )

        await BeaverLogger.shared.configure(config)

        let tag = LogTag(
            subsystem: "com.example.app",
            prefix: "TEST",
            name: "Test"
        )
        let message: LogMessage = "Context test"

        // Use explicit file/function/line so the test is stable if you want:
        await BeaverLogger.shared.log(
            .debug,
            tag: tag,
            message,
            file: "File.swift",
            function: "someFunction()",
            line: 123
        )

        let entry = try XCTUnwrap(sink.entries.first)
        XCTAssertEqual(String(describing: entry.file), "File.swift")
        XCTAssertEqual(String(describing: entry.function), "someFunction()")
        XCTAssertEqual(entry.line, 123)
    }
}

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
        lock.lock()
        defer { lock.unlock() }
        return entriesStorage
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
        lock.lock()
        entriesStorage.append(entry)
        lock.unlock()
    }
}
