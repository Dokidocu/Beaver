import XCTest
import Beaver

/// Verifies the public API of `LogTags` without `@testable` access.
///
/// Each test confirms that a predefined tag constant is accessible, returns a `LogTag`,
/// and has the expected subsystem structure and identifier. If a tag is removed or
/// renamed, or its type changes, the corresponding test will fail to compile.
final class LogTagsPublicAPITests: XCTestCase {
    // MARK: - Core

    func testGeneralTagIsAccessible() {
        // WHEN  LogTags.general is accessed
        // THEN  it is a LogTag with a non-empty subsystem and identifier "General"
        let tag: LogTag = LogTags.general
        XCTAssertFalse(tag.subsystem.isEmpty)
        XCTAssertEqual(tag.identifier, "General")
    }

    func testLifecycleTagIsAccessible() {
        // WHEN  LogTags.lifecycle is accessed
        // THEN  it is a LogTag with a non-empty subsystem and identifier "APP Lifecycle"
        let tag: LogTag = LogTags.lifecycle
        XCTAssertFalse(tag.subsystem.isEmpty)
        XCTAssertEqual(tag.identifier, "APP Lifecycle")
    }

    func testPerformanceTagIsAccessible() {
        // WHEN  LogTags.performance is accessed
        // THEN  it is a LogTag with a non-empty subsystem and a non-empty identifier
        let tag: LogTag = LogTags.performance
        XCTAssertFalse(tag.subsystem.isEmpty)
        XCTAssertFalse(tag.identifier.isEmpty)
    }

    // MARK: - Networking

    func testNetworkTagIsAccessible() {
        // WHEN  LogTags.network is accessed
        // THEN  it is a LogTag whose subsystem ends with ".network"
        let tag: LogTag = LogTags.network
        XCTAssertTrue(tag.subsystem.hasSuffix(".network"))
        XCTAssertFalse(tag.identifier.isEmpty)
    }

    func testApiTagIsAccessible() {
        // WHEN  LogTags.api is accessed
        // THEN  it is a LogTag whose subsystem ends with ".api" and identifier is "API API"
        let tag: LogTag = LogTags.api
        XCTAssertTrue(tag.subsystem.hasSuffix(".api"))
        XCTAssertEqual(tag.identifier, "API API")
    }

    // MARK: - Security

    func testAuthTagIsAccessible() {
        // WHEN  LogTags.auth is accessed
        // THEN  it is a LogTag whose subsystem ends with ".auth"
        let tag: LogTag = LogTags.auth
        XCTAssertTrue(tag.subsystem.hasSuffix(".auth"))
        XCTAssertFalse(tag.identifier.isEmpty)
    }

    func testOAuthTagIsAccessible() {
        // WHEN  LogTags.oauth is accessed
        // THEN  it is a LogTag whose subsystem ends with ".oauth" and identifier is "OAUTH OAuth"
        let tag: LogTag = LogTags.oauth
        XCTAssertTrue(tag.subsystem.hasSuffix(".oauth"))
        XCTAssertEqual(tag.identifier, "OAUTH OAuth")
    }

    // MARK: - UI

    func testUITagIsAccessible() {
        // WHEN  LogTags.ui is accessed
        // THEN  it is a LogTag whose subsystem ends with ".ui" and identifier is "UI UI"
        let tag: LogTag = LogTags.ui
        XCTAssertTrue(tag.subsystem.hasSuffix(".ui"))
        XCTAssertEqual(tag.identifier, "UI UI")
    }

    func testAccessibilityTagIsAccessible() {
        // WHEN  LogTags.accessibility is accessed
        // THEN  it is a LogTag whose subsystem ends with ".accessibility"
        let tag: LogTag = LogTags.accessibility
        XCTAssertTrue(tag.subsystem.hasSuffix(".accessibility"))
        XCTAssertFalse(tag.identifier.isEmpty)
    }

    // MARK: - Uniqueness

    func testAllTagsAreDistinct() {
        // GIVEN all nine predefined LogTags collected into an array
        let tags: [LogTag] = [
            LogTags.general,
            LogTags.lifecycle,
            LogTags.performance,
            LogTags.network,
            LogTags.api,
            LogTags.auth,
            LogTags.oauth,
            LogTags.ui,
            LogTags.accessibility
        ]

        // WHEN  placed into a Set
        // THEN  every tag is unique — none share the same subsystem+prefix+name combination
        XCTAssertEqual(Set(tags).count, tags.count, "All predefined LogTags must be unique")
    }

    // MARK: - Hashable (usable as dictionary key)

    func testTagsAreUsableAsDictionaryKeys() {
        // GIVEN LogTag values used as dictionary keys
        var dict: [LogTag: String] = [:]
        dict[LogTags.network] = "network"
        dict[LogTags.auth] = "auth"

        // WHEN  values are stored and retrieved by key
        // THEN  the correct values are returned, confirming Hashable conformance
        XCTAssertEqual(dict[LogTags.network], "network")
        XCTAssertEqual(dict[LogTags.auth], "auth")
    }
}
