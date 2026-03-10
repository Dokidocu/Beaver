import XCTest
@testable import Beaver

final class LoggerFacadeTests: XCTestCase {
    private let tag = LogTag(subsystem: "com.example.app", prefix: "TEST", name: "Test")

    func testWriteLogForwardsToSinkWhenLevelPassesFilter() {
        // GIVEN a LoggerFacade with minimumLevel .debug and a TestSink
        let sink = TestSink()
        let facade = LoggerFacade(sink: sink, minimumLevel: .debug)

        // WHEN  writeLog is called with level .info
        facade.writeLog(
            logLevel: .info,
            logTag: tag,
            message: "Hello",
            context: LogContext(file: "File.swift", function: "fn()", line: 1)
        )

        // THEN  the sink receives exactly one entry with level .info and the expected message
        XCTAssertEqual(sink.entries.count, 1)
        XCTAssertEqual(sink.entries.first?.level, .info)
        XCTAssertEqual(sink.entries.first?.message, "Hello")
    }

    func testWriteLogFiltersMessagesBelowMinimumLevel() {
        // GIVEN a LoggerFacade with minimumLevel .info
        let sink = TestSink()
        let facade = LoggerFacade(sink: sink, minimumLevel: .info)

        // WHEN  writeLog is called with level .debug (below the minimum)
        facade.writeLog(
            logLevel: .debug,
            logTag: tag,
            message: "Should be filtered",
            context: LogContext(file: "File.swift", function: "fn()", line: 1)
        )

        // THEN  the sink receives no entries
        XCTAssertTrue(sink.entries.isEmpty)
    }

    func testWriteLogPassesMessageAtMinimumLevel() {
        // GIVEN a LoggerFacade with minimumLevel .warning
        let sink = TestSink()
        let facade = LoggerFacade(sink: sink, minimumLevel: .warning)

        // WHEN  writeLog is called at exactly the minimum level
        facade.writeLog(
            logLevel: .warning,
            logTag: tag,
            message: "Boundary message",
            context: LogContext(file: "File.swift", function: "fn()", line: 1)
        )

        // THEN  the sink receives exactly one entry
        XCTAssertEqual(sink.entries.count, 1)
    }

    func testContextInformationIsPassedThrough() throws {
        // GIVEN a LoggerFacade with a specific LogContext (file, function, line)
        let sink = TestSink()
        let facade = LoggerFacade(sink: sink, minimumLevel: .debug)

        // WHEN  writeLog is called with that context
        facade.writeLog(
            logLevel: .debug,
            logTag: tag,
            message: "Context test",
            context: LogContext(file: "File.swift", function: "someFunction()", line: 123)
        )

        // THEN  the entry's file, function, and line match the context
        let entry = try XCTUnwrap(sink.entries.first)
        XCTAssertEqual(String(describing: entry.file), "File.swift")
        XCTAssertEqual(String(describing: entry.function), "someFunction()")
        XCTAssertEqual(entry.line, 123)
    }

    func testTagIsPassedThrough() throws {
        // GIVEN a LoggerFacade and a known LogTag
        let sink = TestSink()
        let facade = LoggerFacade(sink: sink, minimumLevel: .debug)

        // WHEN  writeLog is called with that tag
        facade.writeLog(
            logLevel: .debug,
            logTag: tag,
            message: "Tag test",
            context: LogContext(file: "File.swift", function: "fn()", line: 1)
        )

        // THEN  the entry's tag matches the given tag
        let entry = try XCTUnwrap(sink.entries.first)
        XCTAssertEqual(entry.tag, tag)
    }
}
