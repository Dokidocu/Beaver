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
        LogTag(
            subsystem: subsystem,
            prefix: prefix,
            name: name
        )
    }

    private func makeContext(
        file: StaticString = "MyFile.swift",
        function: StaticString = "myFunction()",
        line: UInt = 42
    ) -> LogContext {
        LogContext(
            file: file,
            function: function,
            line: line
        )
    }

    // MARK: - Subsystem & Category

    func testFormat_UsesTagSubsystemAndIdentifier() {
        let tag = makeTag(
            subsystem: "com.acme.app.network",
            prefix: "NET",
            name: "Network"
        )
        let message: LogMessage = "Hello"
        let context = makeContext()

        let output = formatter.format(
            level: LogLevel.info,
            tag: tag,
            message: message,
            context: context
        )

        XCTAssertEqual(output.subsystem, "com.acme.app.network")
        XCTAssertEqual(output.category, "NET Network")
    }

    func testFormat_UsesTagIdentifierWithoutPrefix() {
        let tag = makeTag(
            subsystem: "com.acme.app",
            prefix: "",
            name: "General"
        )
        let message: LogMessage = "Hello"
        let context = makeContext()

        let output = formatter.format(
            level: LogLevel.info,
            tag: tag,
            message: message,
            context: context
        )

        XCTAssertEqual(output.subsystem, "com.acme.app")
        XCTAssertEqual(output.category, "General")
    }

    // MARK: - Text / Prefix Formatting

    func testFormat_TextContainsMessageValue() {
        let tag = makeTag()
        let message: LogMessage = "Hello \(42)"
        let context = makeContext()

        let output = formatter.format(
            level: LogLevel.info,
            tag: tag,
            message: message,
            context: context
        )

        XCTAssertTrue(
            output.message.contains("Hello 42"),
            "Expected '\(output.message)' to contain interpolated message value"
        )
    }

    func testFormat_TextContainsLogLevelAndSourceLocation() {
        let tag = makeTag()
        let message: LogMessage = "Something happened"
        let context = makeContext(
            file: "FeatureFile.swift",
            function: "doWork()",
            line: 123
        )

        let output = formatter.format(
            level: LogLevel.warning,
            tag: tag,
            message: message,
            context: context
        )

        // Prefix shape: [LEVEL] filename.function.line
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
        let tag = makeTag()
        let message: LogMessage = "Payload"
        let context = makeContext()

        let output = formatter.format(
            level: LogLevel.debug,
            tag: tag,
            message: message,
            context: context
        )

        // we expect something like: "[DEBUG] MyFile.swift.myFunction().42: Payload"
        XCTAssertTrue(
            output.message.contains(": Payload"),
            "Expected log text to contain ': Payload' but was: \(output.message)"
        )
    }
}
