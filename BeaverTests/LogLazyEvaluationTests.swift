import XCTest
@testable import Beaver

final class LogLazyEvaluationTests: XCTestCase {
    private let tag = LogTag(subsystem: "com.example.app", prefix: "TEST", name: "Lazy")

    func testFilteredOutStaticMessageIsNotEvaluated() async {
        // GIVEN a logger configured to filter out debug messages
        let sink = TestSink()
        await Log.configure(.init(minimumLevel: .error, sinks: [sink]))
        var evaluated = false

        func makeMessage() -> LogMessage {
            evaluated = true
            return "Expensive message"
        }

        // WHEN  a filtered debug message is logged
        Log.debug(makeMessage(), tag: tag)

        // THEN  the message expression is never evaluated
        XCTAssertFalse(evaluated)
        XCTAssertTrue(sink.entries.isEmpty)
    }

    func testDeliveredStaticMessageIsEvaluated() async {
        // GIVEN a logger configured to allow debug messages
        let sink = TestSink()
        await Log.configure(.init(minimumLevel: .debug, sinks: [sink]))
        var evaluated = false

        func makeMessage() -> LogMessage {
            evaluated = true
            return "Expensive message"
        }

        // WHEN  a visible debug message is logged
        Log.debug(makeMessage(), tag: tag)

        // THEN  the message expression is evaluated and delivered
        XCTAssertTrue(evaluated)
        XCTAssertEqual(sink.entries.first?.message, "Expensive message")
    }

    func testFilteredOutCoreLogMessageIsNotEvaluated() async {
        // GIVEN a logger configured to filter out info messages
        let sink = TestSink()
        await Log.configure(.init(minimumLevel: .warning, sinks: [sink]))
        var evaluated = false

        func makeMessage() -> LogMessage {
            evaluated = true
            return "Core log message"
        }

        // WHEN  the core log API is used with a filtered level
        Log.shared.log(.info, tag: tag, makeMessage())

        // THEN  the message expression is never evaluated
        XCTAssertFalse(evaluated)
        XCTAssertTrue(sink.entries.isEmpty)
    }
}
