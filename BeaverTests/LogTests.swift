import XCTest
@testable import Beaver

// MARK: - LoggerFacade unit tests (no shared global state, no async)

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

// MARK: - Log nonisolated API tests (no async needed)

final class LogNonisolatedTests: XCTestCase {
    private let tag = LogTag(subsystem: "com.example.app", prefix: "TEST", name: "Nonisolated")

    private func makeSink() async -> TestSink {
        let sink = TestSink()
        await Log.configure(.init(minimumLevel: .debug, sinks: [sink]))
        return sink
    }

    func testInstanceLogMethodRequiresNoAwait() async throws {
        let sink = await makeSink()
        Log.shared.log(.info, tag: tag, "Instance log")
        XCTAssertEqual(sink.entries.count, 1)
        XCTAssertEqual(sink.entries.first?.message, "Instance log")
    }

    func testStaticDebugConvenience() async throws {
        let sink = await makeSink()
        Log.debug("Debug msg", tag: tag)
        XCTAssertEqual(sink.entries.first?.level, .debug)
        XCTAssertEqual(sink.entries.first?.message, "Debug msg")
    }

    func testStaticInfoConvenience() async throws {
        let sink = await makeSink()
        Log.info("Info msg", tag: tag)
        XCTAssertEqual(sink.entries.first?.level, .info)
        XCTAssertEqual(sink.entries.first?.message, "Info msg")
    }

    func testStaticWarningConvenience() async throws {
        let sink = await makeSink()
        Log.warning("Warning msg", tag: tag)
        XCTAssertEqual(sink.entries.first?.level, .warning)
        XCTAssertEqual(sink.entries.first?.message, "Warning msg")
    }

    func testStaticErrorConvenience() async throws {
        let sink = await makeSink()
        Log.error("Error msg", tag: tag)
        XCTAssertEqual(sink.entries.first?.level, .error)
        XCTAssertEqual(sink.entries.first?.message, "Error msg")
    }

    func testDefaultTagIsGeneral() async throws {
        let sink = await makeSink()
        Log.info("No explicit tag")
        XCTAssertEqual(sink.entries.first?.tag, LogTags.general)
    }

    func testMinimumLevelFiltering() async throws {
        let sink = TestSink()
        await Log.configure(.init(minimumLevel: .warning, sinks: [sink]))
        Log.debug("Filtered debug")
        Log.info("Filtered info")
        Log.warning("Visible warning")
        XCTAssertEqual(sink.entries.count, 1)
        XCTAssertEqual(sink.entries.first?.message, "Visible warning")
    }
}

// MARK: - Log integration test (configure replaces pipeline)

final class LogIntegrationTests: XCTestCase {
    func testConfigureReplacesUnderlyingLoggerWithProvidedSinks() async throws {
        let sink = TestSink()
        await Log.shared.configure(
            Log.Configuration(minimumLevel: .debug, sinks: [sink])
        )

        let tag = LogTag(subsystem: "com.example.app", prefix: "TEST", name: "Test")
        Log.shared.log(.info, tag: tag, "Hello")

        XCTAssertEqual(sink.entries.count, 1)
        let entry = try XCTUnwrap(sink.entries.first)
        XCTAssertEqual(entry.level, .info)
        XCTAssertEqual(entry.tag, tag)
        XCTAssertEqual(entry.message, "Hello")
    }
}
