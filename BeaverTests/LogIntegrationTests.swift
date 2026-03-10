import XCTest
@testable import Beaver

final class LogIntegrationTests: XCTestCase {
    func testConfigureReplacesUnderlyingLoggerWithProvidedSinks() async throws {
        // GIVEN a TestSink registered via Log.shared.configure
        let sink = TestSink()
        await Log.shared.configure(
            Log.Configuration(minimumLevel: .debug, sinks: [sink])
        )
        let tag = LogTag(subsystem: "com.example.app", prefix: "TEST", name: "Test")

        // WHEN  Log.shared.log is called with a known level, tag, and message
        Log.shared.log(.info, tag: tag, "Hello")

        // THEN  the sink receives exactly one entry matching the level, tag, and message
        XCTAssertEqual(sink.entries.count, 1)
        let entry = try XCTUnwrap(sink.entries.first)
        XCTAssertEqual(entry.level, .info)
        XCTAssertEqual(entry.tag, tag)
        XCTAssertEqual(entry.message, "Hello")
    }
}
