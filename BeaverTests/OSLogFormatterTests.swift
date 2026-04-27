import XCTest
import OSLog
@testable import Beaver

final class OSLogFormatterTests: XCTestCase {
    private let formatter = OSLogFormatter(sourceFormat: .compact)

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
        let rendered = output.redactedMessage(defaultPrivacy: .public)

        // THEN  the formatted text contains the interpolated message value
        XCTAssertTrue(
            rendered.contains("Hello 42"),
            "Expected '\(rendered)' to contain interpolated message value"
        )
    }

    func testFormat_TextContainsLogLevelAndSourceLocation() {
        // GIVEN a context with file "FeatureFile.swift", function "doWork()", line 123
        let context = makeContext(file: "FeatureFile.swift", function: "doWork()", line: 123)

        // WHEN  the formatter formats a warning-level entry with that context
        let output = formatter.format(level: .warning, tag: makeTag(), message: "Something happened", context: context)
        let rendered = output.redactedMessage(defaultPrivacy: .public)

        // THEN  the formatted text contains the "[WARNING]" prefix and the source location
        XCTAssertTrue(
            rendered.contains("[WARNING]"),
            "Expected log text to contain level prefix '[WARNING]' but was: \(rendered)"
        )
        XCTAssertTrue(
            rendered.contains("FeatureFile.swift:123"),
            "Expected log text to contain source location, but was: \(rendered)"
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
        let rendered = output.redactedMessage(defaultPrivacy: .public)

        // THEN  the formatted text contains ": Payload", separating the prefix from the message
        XCTAssertTrue(
            rendered.contains(": Payload"),
            "Expected log text to contain ': Payload' but was: \(rendered)"
        )
    }

    func testFormat_TextContainsTagAfterLevel() {
        // GIVEN a formatter and a tag named "Network"
        let tag = makeTag(name: "Network")

        // WHEN  the formatter formats an entry
        let output = formatter.format(level: .info, tag: tag, message: "Hello", context: makeContext())
        let rendered = output.redactedMessage(defaultPrivacy: .public)

        // THEN  the formatted text includes the tag after the level
        XCTAssertTrue(
            rendered.contains("[INFO] [Network]"),
            "Expected log text to contain level and tag, but was: \(rendered)"
        )
    }

    func testFormat_FullSourceFormatIncludesFileFunctionAndLine() {
        // GIVEN a formatter configured with full source output
        let formatter = OSLogFormatter(sourceFormat: .full)
        let context = makeContext(file: "FeatureFile.swift", function: "doWork()", line: 123)

        // WHEN  the formatter formats an entry
        let output = formatter.format(level: .debug, tag: makeTag(), message: "Payload", context: context)

        // THEN  the message includes file, function, and line
        XCTAssertTrue(output.redactedMessage(defaultPrivacy: .public).contains("FeatureFile.swift.doWork().123"))
    }

    func testFormat_CompactSourceFormatIncludesFileAndLineOnly() {
        // GIVEN a formatter configured with compact source output
        let formatter = OSLogFormatter(sourceFormat: .compact)
        let context = makeContext(file: "FeatureFile.swift", function: "doWork()", line: 123)

        // WHEN  the formatter formats an entry
        let output = formatter.format(level: .debug, tag: makeTag(), message: "Payload", context: context)

        // THEN  the message includes file and line without the function
        let rendered = output.redactedMessage(defaultPrivacy: .public)
        XCTAssertTrue(rendered.contains("FeatureFile.swift:123"))
        XCTAssertFalse(rendered.contains("doWork()"))
    }

    func testFormat_NoSourceFormatOmitsSourceLocation() {
        // GIVEN a formatter configured with no source output
        let formatter = OSLogFormatter(sourceFormat: .none)
        let context = makeContext(file: "FeatureFile.swift", function: "doWork()", line: 123)

        // WHEN  the formatter formats an entry
        let output = formatter.format(level: .error, tag: makeTag(), message: "Payload", context: context)

        // THEN  the output contains only the level, tag, and message
        XCTAssertEqual(output.redactedMessage(defaultPrivacy: .public), "[ERROR] [Network] Payload")
    }

    func testFormat_RedactsOnlyInheritedInterpolationsWhenDefaultPrivacyIsPrivate() {
        // GIVEN a message with one literal prefix and one inherited interpolation
        let output = formatter.format(
            level: .info,
            tag: makeTag(),
            message: "Signed in user \("alice@example.com")",
            context: makeContext()
        )

        // WHEN  the default privacy is private
        let rendered = output.redactedMessage(defaultPrivacy: .private)

        // THEN  the literal text remains visible while the interpolated value is redacted
        XCTAssertEqual(rendered, "[INFO] [Network] MyFile.swift:42: Signed in user <private>")
    }

    func testFormat_RespectsExplicitPrivateAndPublicInterpolations() {
        // GIVEN a message with both explicit public and explicit private interpolation
        let output = formatter.format(
            level: .info,
            tag: makeTag(),
            message: "Build \(public: "Debug") for \("user") \(private: "alice@example.com")",
            context: makeContext()
        )

        // WHEN  the default privacy is public
        let rendered = output.redactedMessage(defaultPrivacy: .public)

        // THEN  explicit private values are redacted while explicit public values remain visible
        XCTAssertEqual(rendered, "[INFO] [Network] MyFile.swift:42: Build Debug for user <private>")
    }
}
