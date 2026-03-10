import XCTest
import Beaver

/// Verifies the public API of the `Log` actor without `@testable` access.
///
/// Every test in this file accesses only types and methods that are part of
/// the published surface of the Beaver module. If any public declaration is
/// renamed, removed, or made internal, the corresponding test will fail to compile,
/// catching the breaking change before it reaches consumers.
final class LogPublicAPITests: XCTestCase {
    // MARK: - Shared instance

    func testSharedInstanceIsAccessible() {
        // WHEN  Log.shared is accessed
        // THEN  it compiles, confirming the static property is public
        _ = Log.shared
    }

    // MARK: - Static configure

    func testStaticConfigureAcceptsConfiguration() async {
        // GIVEN a PublicSink registered via the static configure overload
        let sink = PublicSink()
        await Log.configure(Log.Configuration(minimumLevel: .debug, sinks: [sink]))

        // WHEN  a message is logged
        Log.info("configured via static")

        // THEN  the sink receives exactly one entry
        XCTAssertEqual(sink.entries.count, 1)
    }

    // MARK: - Instance configure

    func testInstanceConfigureAcceptsConfiguration() async {
        // GIVEN a PublicSink registered via the instance configure overload
        let sink = PublicSink()
        await Log.shared.configure(Log.Configuration(minimumLevel: .debug, sinks: [sink]))

        // WHEN  a message is logged via the instance
        Log.shared.info("configured via instance")

        // THEN  the sink receives exactly one entry
        XCTAssertEqual(sink.entries.count, 1)
    }

    // MARK: - Static convenience methods (synchronous — no await)

    func testStaticDebugLogsWithoutAwait() async {
        // GIVEN a PublicSink with minimumLevel .debug
        let sink = PublicSink()
        await Log.configure(Log.Configuration(minimumLevel: .debug, sinks: [sink]))

        // WHEN  Log.debug is called (no await)
        Log.debug("static debug")

        // THEN  the sink receives an entry with the correct level and message
        XCTAssertEqual(sink.entries.first?.level, .debug)
        XCTAssertEqual(sink.entries.first?.message, "static debug")
    }

    func testStaticInfoLogsWithoutAwait() async {
        // GIVEN a PublicSink with minimumLevel .debug
        let sink = PublicSink()
        await Log.configure(Log.Configuration(minimumLevel: .debug, sinks: [sink]))

        // WHEN  Log.info is called (no await)
        Log.info("static info")

        // THEN  the sink receives an entry with level .info and the expected message
        XCTAssertEqual(sink.entries.first?.level, .info)
        XCTAssertEqual(sink.entries.first?.message, "static info")
    }

    func testStaticWarningLogsWithoutAwait() async {
        // GIVEN a PublicSink with minimumLevel .debug
        let sink = PublicSink()
        await Log.configure(Log.Configuration(minimumLevel: .debug, sinks: [sink]))

        // WHEN  Log.warning is called (no await)
        Log.warning("static warning")

        // THEN  the sink receives an entry with level .warning and the expected message
        XCTAssertEqual(sink.entries.first?.level, .warning)
        XCTAssertEqual(sink.entries.first?.message, "static warning")
    }

    func testStaticErrorLogsWithoutAwait() async {
        // GIVEN a PublicSink with minimumLevel .debug
        let sink = PublicSink()
        await Log.configure(Log.Configuration(minimumLevel: .debug, sinks: [sink]))

        // WHEN  Log.error is called (no await)
        Log.error("static error")

        // THEN  the sink receives an entry with level .error and the expected message
        XCTAssertEqual(sink.entries.first?.level, .error)
        XCTAssertEqual(sink.entries.first?.message, "static error")
    }

    // MARK: - Instance convenience methods (synchronous — no await)

    func testInstanceDebugLogsWithoutAwait() async {
        // GIVEN a PublicSink with minimumLevel .debug
        let sink = PublicSink()
        await Log.configure(Log.Configuration(minimumLevel: .debug, sinks: [sink]))

        // WHEN  Log.shared.debug is called (no await)
        Log.shared.debug("instance debug")

        // THEN  the sink receives an entry with level .debug and the expected message
        XCTAssertEqual(sink.entries.first?.level, .debug)
        XCTAssertEqual(sink.entries.first?.message, "instance debug")
    }

    func testInstanceInfoLogsWithoutAwait() async {
        // GIVEN a PublicSink with minimumLevel .debug
        let sink = PublicSink()
        await Log.configure(Log.Configuration(minimumLevel: .debug, sinks: [sink]))

        // WHEN  Log.shared.info is called (no await)
        Log.shared.info("instance info")

        // THEN  the sink receives an entry with level .info and the expected message
        XCTAssertEqual(sink.entries.first?.level, .info)
        XCTAssertEqual(sink.entries.first?.message, "instance info")
    }

    func testInstanceWarningLogsWithoutAwait() async {
        // GIVEN a PublicSink with minimumLevel .debug
        let sink = PublicSink()
        await Log.configure(Log.Configuration(minimumLevel: .debug, sinks: [sink]))

        // WHEN  Log.shared.warning is called (no await)
        Log.shared.warning("instance warning")

        // THEN  the sink receives an entry with level .warning and the expected message
        XCTAssertEqual(sink.entries.first?.level, .warning)
        XCTAssertEqual(sink.entries.first?.message, "instance warning")
    }

    func testInstanceErrorLogsWithoutAwait() async {
        // GIVEN a PublicSink with minimumLevel .debug
        let sink = PublicSink()
        await Log.configure(Log.Configuration(minimumLevel: .debug, sinks: [sink]))

        // WHEN  Log.shared.error is called (no await)
        Log.shared.error("instance error")

        // THEN  the sink receives an entry with level .error and the expected message
        XCTAssertEqual(sink.entries.first?.level, .error)
        XCTAssertEqual(sink.entries.first?.message, "instance error")
    }

    // MARK: - Core log(_:tag:_:) method

    func testCoreLogMethodAcceptsAllLevels() async {
        // GIVEN a PublicSink with minimumLevel .debug
        let sink = PublicSink()
        let tag = LogTag(subsystem: "com.example.app", prefix: "T", name: "Test")
        await Log.configure(Log.Configuration(minimumLevel: .debug, sinks: [sink]))

        // WHEN  log(_:tag:_:) is called once for each of the four levels
        Log.shared.log(.debug, tag: tag, "d")
        Log.shared.log(.info, tag: tag, "i")
        Log.shared.log(.warning, tag: tag, "w")
        Log.shared.log(.error, tag: tag, "e")

        // THEN  the sink receives four entries with levels in severity order
        XCTAssertEqual(sink.entries.count, 4)
        XCTAssertEqual(sink.entries[0].level, .debug)
        XCTAssertEqual(sink.entries[1].level, .info)
        XCTAssertEqual(sink.entries[2].level, .warning)
        XCTAssertEqual(sink.entries[3].level, .error)
    }

    // MARK: - Tag forwarding

    func testTagIsForwardedToSink() async throws {
        // GIVEN a custom LogTag and a PublicSink
        let sink = PublicSink()
        let tag = LogTag(subsystem: "com.example.app", prefix: "UI", name: "Screen")
        await Log.configure(Log.Configuration(minimumLevel: .debug, sinks: [sink]))

        // WHEN  log is called with that tag
        Log.shared.log(.info, tag: tag, "with tag")

        // THEN  the entry's tag matches the custom tag
        XCTAssertEqual(try XCTUnwrap(sink.entries.first).tag, tag)
    }

    func testDefaultTagIsGeneral() async throws {
        // GIVEN a PublicSink with no explicit tag provided at the call site
        let sink = PublicSink()
        await Log.configure(Log.Configuration(minimumLevel: .debug, sinks: [sink]))

        // WHEN  Log.info is called without a tag argument
        Log.info("no explicit tag")

        // THEN  the entry's tag is LogTags.general
        XCTAssertEqual(try XCTUnwrap(sink.entries.first).tag, LogTags.general)
    }

    // MARK: - Level filtering

    func testMessagesAboveMinimumLevelAreDelivered() async {
        // GIVEN minimumLevel set to .warning
        let sink = PublicSink()
        await Log.configure(Log.Configuration(minimumLevel: .warning, sinks: [sink]))

        // WHEN  debug, info, warning, and error messages are all logged
        Log.debug("filtered")
        Log.info("filtered")
        Log.warning("delivered")
        Log.error("delivered")

        // THEN  only the warning and error entries reach the sink
        XCTAssertEqual(sink.entries.count, 2)
        XCTAssertEqual(sink.entries[0].level, .warning)
        XCTAssertEqual(sink.entries[1].level, .error)
    }

    func testMessageAtExactMinimumLevelIsDelivered() async throws {
        // GIVEN minimumLevel set to .error
        let sink = PublicSink()
        await Log.configure(Log.Configuration(minimumLevel: .error, sinks: [sink]))

        // WHEN  a message is logged at exactly the minimum level
        Log.error("at boundary")

        // THEN  the sink receives that entry
        XCTAssertEqual(try XCTUnwrap(sink.entries.first).level, .error)
    }

    // MARK: - Context capture

    func testContextFileIsForwardedToSink() async throws {
        // GIVEN a PublicSink configured as the active sink
        let sink = PublicSink()
        await Log.configure(Log.Configuration(minimumLevel: .debug, sinks: [sink]))

        // WHEN  Log.info is called
        Log.info("context")

        // THEN  the entry's file contains the name of this test file
        let file = String(describing: try XCTUnwrap(sink.entries.first).file)
        XCTAssertTrue(file.contains("LogPublicAPITests"), "Expected file to contain 'LogPublicAPITests', got: \(file)")
    }

    func testContextFunctionAndLineAreForwardedToSink() async throws {
        // GIVEN a PublicSink configured as the active sink
        let sink = PublicSink()
        await Log.configure(Log.Configuration(minimumLevel: .debug, sinks: [sink]))

        // WHEN  Log.info is called
        Log.info("fn and line")

        // THEN  the entry's function is non-empty and line is greater than zero
        let entry = try XCTUnwrap(sink.entries.first)
        XCTAssertFalse(String(describing: entry.function).isEmpty)
        XCTAssertGreaterThan(entry.line, 0)
    }

    // MARK: - Multiple sinks

    func testAllConfiguredSinksReceiveMessages() async {
        // GIVEN two PublicSinks registered together
        let sink1 = PublicSink()
        let sink2 = PublicSink()
        await Log.configure(Log.Configuration(minimumLevel: .debug, sinks: [sink1, sink2]))

        // WHEN  a single message is logged
        Log.info("fan-out")

        // THEN  both sinks each receive exactly one entry
        XCTAssertEqual(sink1.entries.count, 1)
        XCTAssertEqual(sink2.entries.count, 1)
    }
}
