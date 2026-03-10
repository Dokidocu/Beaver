import XCTest
import OSLog
@testable import Beaver

final class OSLogFormatterTests: XCTestCase {
    private let formatter = OSLogFormatter()

    // MARK: - Helpers

    private func makeTag(
        subsystem: String = "com.example.app",
        prefix: StaticString = "NET",
        name: StaticString = "Network"
    ) -> LogTag {
        LogTag(subsystem: subsystem, prefix: prefix, name: name)
    }

    private func makeContext(
        file: StaticString = "MyFile.swift",
        function: StaticString = "myFunction()",
        line: UInt = 42
    ) -> LogContext {
        LogContext(file: file, function: function, line: line)
    }

    // MARK: - Subsystem & Category

    func testFormat_UsesTagSubsystemAndIdentifier() {
        // GIVEN a LogTag with a specific subsystem and "NET Network" identifier
        let tag = makeTag(subsystem: "com.acme.app.network", prefix: "NET", name: "Network")

        // WHEN  the formatter formats an entry with that tag
        let output = formatter.format(level: .info, tag: tag, message: "Hello", context: makeContext())

        // THEN  output.subsystem and output.category match the tag's values
        XCTAssertEqual(output.subsystem, "com.acme.app.network")
        XCTAssertEqual(output.category, "NET Network")
    }

    func testFormat_UsesTagIdentifierWithoutPrefix() {
        // GIVEN a LogTag with an empty prefix and name "General"
        let tag = makeTag(subsystem: "com.acme.app", prefix: "", name: "General")

        // WHEN  the formatter formats an entry with that tag
        let output = formatter.format(level: .info, tag: tag, message: "Hello", context: makeContext())

        // THEN  output.category equals just the name "General"
        XCTAssertEqual(output.subsystem, "com.acme.app")
        XCTAssertEqual(output.category, "General")
    }

    // MARK: - Message content

    func testFormat_TextContainsMessageValue() {
        // GIVEN a message with interpolated content "Hello 42"
        let message: LogMessage = "Hello \(42)"

        // WHEN  the formatter formats the entry
        let output = formatter.format(level: .info, tag: makeTag(), message: message, context: makeContext())

        // THEN  the formatted text contains the interpolated message value
        XCTAssertTrue(
            output.message.contains("Hello 42"),
            "Expected '\(output.message)' to contain interpolated message value"
        )
    }

    func testFormat_TextContainsLogLevelAndSourceLocation() {
        // GIVEN a context with file "FeatureFile.swift", function "doWork()", line 123
        let context = makeContext(file: "FeatureFile.swift", function: "doWork()", line: 123)

        // WHEN  the formatter formats a warning-level entry with that context
        let output = formatter.format(level: .warning, tag: makeTag(), message: "Something happened", context: context)

        // THEN  the formatted text contains the "[WARNING]" prefix and the source location
        XCTAssertTrue(
            output.message.contains("[WARNING]"),
            "Expected log text to contain level prefix '[WARNING]' but was: \(output.message)"
        )
        XCTAssertTrue(
            output.message.contains("FeatureFile.swift.doWork().123"),
            "Expected log text to contain source location, but was: \(output.message)"
        )
    }

    func testFormat_PrefixAndMessageSeparatedByColon() {
        // GIVEN a message "Payload" and a standard context
        // WHEN  the formatter formats a debug-level entry
        let output = formatter.format(
            level: .debug,
            tag: makeTag(),
            message: "Payload",
            context: makeContext()
        )

        // THEN  the formatted text contains ": Payload", separating the prefix from the message
        XCTAssertTrue(
            output.message.contains(": Payload"),
            "Expected log text to contain ': Payload' but was: \(output.message)"
        )
    }
}
