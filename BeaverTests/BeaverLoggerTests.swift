import XCTest
@testable import Beaver

// MARK: - LoggerFacade unit tests (no shared global state)

final class LoggerFacadeTests: XCTestCase {
    private let tag = LogTag(subsystem: "com.example.app", prefix: "TEST", name: "Test")

    func testWriteLogForwardsToSinkWhenLevelPassesFilter() {
        let sink = TestSink()
        let facade = LoggerFacade(sink: sink, minimumLevel: .debug)

        facade.writeLog(
            logLevel: .info,
            logTag: tag,
            message: "Hello",
            context: LogContext(file: "File.swift", function: "fn()", line: 1)
        )

        XCTAssertEqual(sink.entries.count, 1)
        XCTAssertEqual(sink.entries.first?.level, .info)
        XCTAssertEqual(sink.entries.first?.message, "Hello")
    }

    func testWriteLogFiltersMessagesBelowMinimumLevel() {
        let sink = TestSink()
        let facade = LoggerFacade(sink: sink, minimumLevel: .info)

        facade.writeLog(
            logLevel: .debug,
            logTag: tag,
            message: "Should be filtered",
            context: LogContext(file: "File.swift", function: "fn()", line: 1)
        )

        XCTAssertTrue(sink.entries.isEmpty)
    }

    func testWriteLogPassesMessageAtMinimumLevel() {
        let sink = TestSink()
        let facade = LoggerFacade(sink: sink, minimumLevel: .warning)

        facade.writeLog(
            logLevel: .warning,
            logTag: tag,
            message: "Boundary message",
            context: LogContext(file: "File.swift", function: "fn()", line: 1)
        )

        XCTAssertEqual(sink.entries.count, 1)
    }

    func testContextInformationIsPassedThrough() throws {
        let sink = TestSink()
        let facade = LoggerFacade(sink: sink, minimumLevel: .debug)

        facade.writeLog(
            logLevel: .debug,
            logTag: tag,
            message: "Context test",
            context: LogContext(file: "File.swift", function: "someFunction()", line: 123)
        )

        let entry = try XCTUnwrap(sink.entries.first)
        XCTAssertEqual(String(describing: entry.file), "File.swift")
        XCTAssertEqual(String(describing: entry.function), "someFunction()")
        XCTAssertEqual(entry.line, 123)
    }

    func testTagIsPassedThrough() throws {
        let sink = TestSink()
        let facade = LoggerFacade(sink: sink, minimumLevel: .debug)

        facade.writeLog(
            logLevel: .debug,
            logTag: tag,
            message: "Tag test",
            context: LogContext(file: "File.swift", function: "fn()", line: 1)
        )

        let entry = try XCTUnwrap(sink.entries.first)
        XCTAssertEqual(entry.tag, tag)
    }
}

// MARK: - BeaverLogger integration test (uses shared actor)

final class BeaverLoggerIntegrationTests: XCTestCase {
    func testConfigureReplacesUnderlyingLoggerWithProvidedSinks() async throws {
        let sink = TestSink()
        await BeaverLogger.shared.configure(
            BeaverLogger.Configuration(minimumLevel: .debug, sinks: [sink])
        )

        let tag = LogTag(subsystem: "com.example.app", prefix: "TEST", name: "Test")
        await BeaverLogger.shared.log(.info, tag: tag, "Hello")

        XCTAssertEqual(sink.entries.count, 1)
        let entry = try XCTUnwrap(sink.entries.first)
        XCTAssertEqual(entry.level, .info)
        XCTAssertEqual(entry.tag, tag)
        XCTAssertEqual(entry.message, "Hello")
    }
}
