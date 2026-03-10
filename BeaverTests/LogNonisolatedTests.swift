import XCTest
@testable import Beaver

final class LogNonisolatedTests: XCTestCase {
    private let tag = LogTag(subsystem: "com.example.app", prefix: "TEST", name: "Nonisolated")

    private func makeSink() async -> TestSink {
        let sink = TestSink()
        await Log.configure(.init(minimumLevel: .debug, sinks: [sink]))
        return sink
    }

    func testInstanceLogMethodRequiresNoAwait() async throws {
        // GIVEN the shared logger configured with a TestSink
        let sink = await makeSink()

        // WHEN  Log.shared.log is called without await
        Log.shared.log(.info, tag: tag, "Instance log")

        // THEN  the sink receives exactly one entry with the expected message
        XCTAssertEqual(sink.entries.count, 1)
        XCTAssertEqual(sink.entries.first?.message, "Instance log")
    }

    func testStaticDebugConvenience() async throws {
        // GIVEN the shared logger configured with a TestSink
        let sink = await makeSink()

        // WHEN  Log.debug is called
        Log.debug("Debug msg", tag: tag)

        // THEN  the sink receives an entry with level .debug and the expected message
        XCTAssertEqual(sink.entries.first?.level, .debug)
        XCTAssertEqual(sink.entries.first?.message, "Debug msg")
    }

    func testStaticInfoConvenience() async throws {
        // GIVEN the shared logger configured with a TestSink
        let sink = await makeSink()

        // WHEN  Log.info is called
        Log.info("Info msg", tag: tag)

        // THEN  the sink receives an entry with level .info and the expected message
        XCTAssertEqual(sink.entries.first?.level, .info)
        XCTAssertEqual(sink.entries.first?.message, "Info msg")
    }

    func testStaticWarningConvenience() async throws {
        // GIVEN the shared logger configured with a TestSink
        let sink = await makeSink()

        // WHEN  Log.warning is called
        Log.warning("Warning msg", tag: tag)

        // THEN  the sink receives an entry with level .warning and the expected message
        XCTAssertEqual(sink.entries.first?.level, .warning)
        XCTAssertEqual(sink.entries.first?.message, "Warning msg")
    }

    func testStaticErrorConvenience() async throws {
        // GIVEN the shared logger configured with a TestSink
        let sink = await makeSink()

        // WHEN  Log.error is called
        Log.error("Error msg", tag: tag)

        // THEN  the sink receives an entry with level .error and the expected message
        XCTAssertEqual(sink.entries.first?.level, .error)
        XCTAssertEqual(sink.entries.first?.message, "Error msg")
    }

    func testDefaultTagIsGeneral() async throws {
        // GIVEN the shared logger configured with a TestSink and no explicit tag at the call site
        let sink = await makeSink()

        // WHEN  Log.info is called without a tag argument
        Log.info("No explicit tag")

        // THEN  the entry's tag equals LogTags.general
        XCTAssertEqual(sink.entries.first?.tag, LogTags.general)
    }

    func testMinimumLevelFiltering() async throws {
        // GIVEN minimumLevel set to .warning
        let sink = TestSink()
        await Log.configure(.init(minimumLevel: .warning, sinks: [sink]))

        // WHEN  debug, info, and warning messages are logged
        Log.debug("Filtered debug")
        Log.info("Filtered info")
        Log.warning("Visible warning")

        // THEN  only the warning entry reaches the sink
        XCTAssertEqual(sink.entries.count, 1)
        XCTAssertEqual(sink.entries.first?.message, "Visible warning")
    }
}
