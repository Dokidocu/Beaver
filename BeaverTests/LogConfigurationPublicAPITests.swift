import XCTest
import Beaver

/// Verifies the public API of `Log.Configuration` without `@testable` access.
///
/// These tests guard the struct's initialiser signatures, default values, stored properties,
/// and `Sendable` conformance. A compile failure here indicates a breaking API change.
final class LogConfigurationPublicAPITests: XCTestCase {
    // MARK: - Default initialiser

    func testDefaultMinimumLevelIsDebug() {
        // WHEN  Log.Configuration is created with no arguments
        // THEN  minimumLevel is .debug
        XCTAssertEqual(Log.Configuration().minimumLevel, .debug)
    }

    func testDefaultSinksContainOneOSLogSink() {
        // WHEN  Log.Configuration is created with no arguments
        // THEN  sinks contains exactly one element, and it is an OSLogSink
        let config = Log.Configuration()
        XCTAssertEqual(config.sinks.count, 1)
        XCTAssertTrue(config.sinks.first is OSLogSink)
    }

    // MARK: - Custom initialiser

    func testCustomMinimumLevelIsStored() {
        // GIVEN minimumLevel .error passed to the initialiser
        // WHEN  Configuration is created
        // THEN  minimumLevel equals .error
        XCTAssertEqual(Log.Configuration(minimumLevel: .error).minimumLevel, .error)
    }

    func testCustomSinksAreStored() {
        // GIVEN one custom sink passed to the initialiser
        // WHEN  Configuration is created
        // THEN  sinks contains exactly one element
        let config = Log.Configuration(minimumLevel: .info, sinks: [PublicSink()])
        XCTAssertEqual(config.sinks.count, 1)
    }

    func testEmptySinkListIsAccepted() {
        // GIVEN an empty array passed as sinks
        // WHEN  Configuration is created
        // THEN  sinks is empty
        XCTAssertTrue(Log.Configuration(minimumLevel: .debug, sinks: []).sinks.isEmpty)
    }

    func testMultipleSinksAreStored() {
        // GIVEN two sinks passed to the initialiser
        // WHEN  Configuration is created
        // THEN  sinks contains exactly two elements
        let config = Log.Configuration(minimumLevel: .debug, sinks: [PublicSink(), PublicSink()])
        XCTAssertEqual(config.sinks.count, 2)
    }

    // MARK: - Property access (compile-time checks)

    func testMinimumLevelPropertyIsReadable() {
        // WHEN  minimumLevel is read from a Configuration
        // THEN  it is typed as LogLevel, confirming the property is public
        let _: LogLevel = Log.Configuration(minimumLevel: .info).minimumLevel
    }

    func testSinksPropertyIsReadable() {
        // WHEN  sinks is read from a Configuration
        // THEN  it is typed as [any LogSink], confirming the property is public
        let _: [any LogSink] = Log.Configuration().sinks
    }

    // MARK: - Sendable (compile-time check)

    func testConfigurationCanBeSentAcrossActorBoundary() async {
        // GIVEN a Log.Configuration value
        let config = Log.Configuration(minimumLevel: .info, sinks: [OSLogSink()])

        // WHEN  passed to await Log.configure(_:), which crosses an actor boundary
        // THEN  it compiles, confirming Configuration: Sendable
        await Log.configure(config)
    }
}
