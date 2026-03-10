import XCTest
import Beaver

/// Verifies the public API of the `LogSink` protocol and `OSLogSink` without `@testable` access.
///
/// The compile-time tests here confirm that:
/// - `LogSink` can be conformed to from outside the module (see `PublicSink.swift`)
/// - `OSLogSink` is publicly accessible and conforms to `LogSink`
/// - The `writeLog` method signature (parameters, types) has not changed
final class LogSinkPublicAPITests: XCTestCase {
    // MARK: - Compile-time conformance checks

    func testCustomTypeConformsToLogSinkWithoutTestable() {
        // WHEN  PublicSink is used as any LogSink
        // THEN  the assignment compiles, confirming LogSink is conformable from outside the module
        let _: any LogSink = PublicSink()
    }

    func testOSLogSinkConformsToLogSink() {
        // WHEN  OSLogSink is used as any LogSink
        // THEN  the assignment compiles, confirming OSLogSink publicly conforms to LogSink
        let _: any LogSink = OSLogSink()
    }

    func testOSLogSinkConformsToSendable() {
        // WHEN  OSLogSink is used as any LogSink & Sendable
        // THEN  the assignment compiles, confirming OSLogSink is Sendable
        let _: any LogSink & Sendable = OSLogSink()
    }

    func testOSLogSinkCanBeInitialisedWithoutArguments() {
        // WHEN  OSLogSink() is called
        // THEN  it compiles, confirming the public no-argument initialiser exists
        _ = OSLogSink()
    }

    // MARK: - Sink receives correct data

    func testSinkReceivesExpectedLogLevel() async throws {
        // GIVEN a PublicSink configured as the active sink
        let sink = PublicSink()
        await Log.configure(Log.Configuration(minimumLevel: .debug, sinks: [sink]))

        // WHEN  Log.warning is called
        Log.warning("level check")

        // THEN  the entry received by the sink has level .warning
        XCTAssertEqual(try XCTUnwrap(sink.entries.first).level, .warning)
    }

    func testSinkReceivesExpectedTag() async throws {
        // GIVEN a custom LogTag and a PublicSink
        let tag = LogTag(subsystem: "com.test", prefix: "T", name: "SinkTag")
        let sink = PublicSink()
        await Log.configure(Log.Configuration(minimumLevel: .debug, sinks: [sink]))

        // WHEN  log is called with that tag
        Log.shared.log(.info, tag: tag, "tag check")

        // THEN  the entry's tag matches the custom tag
        XCTAssertEqual(try XCTUnwrap(sink.entries.first).tag, tag)
    }

    func testSinkReceivesExpectedMessageValue() async throws {
        // GIVEN a PublicSink configured as the active sink
        let sink = PublicSink()
        await Log.configure(Log.Configuration(minimumLevel: .debug, sinks: [sink]))

        // WHEN  Log.info is called with a known message string
        Log.info("hello from sink test")

        // THEN  the entry's message matches that string
        XCTAssertEqual(try XCTUnwrap(sink.entries.first).message, "hello from sink test")
    }

    func testSinkReceivesNonEmptyContext() async throws {
        // GIVEN a PublicSink configured as the active sink
        let sink = PublicSink()
        await Log.configure(Log.Configuration(minimumLevel: .debug, sinks: [sink]))

        // WHEN  Log.debug is called
        Log.debug("context check")

        // THEN  the entry's file and function are non-empty, and line is greater than zero
        let entry = try XCTUnwrap(sink.entries.first)
        XCTAssertFalse(String(describing: entry.file).isEmpty)
        XCTAssertFalse(String(describing: entry.function).isEmpty)
        XCTAssertGreaterThan(entry.line, 0)
    }
}
