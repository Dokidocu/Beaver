import XCTest
import Beaver

final class LogLevelTests: XCTestCase {
    // MARK: - Raw values

    func testRawValues() {
        // WHEN  the raw value of each LogLevel case is read
        // THEN  they follow ascending integer order from debug (0) to error (3)
        XCTAssertEqual(LogLevel.debug.rawValue, 0)
        XCTAssertEqual(LogLevel.info.rawValue, 1)
        XCTAssertEqual(LogLevel.warning.rawValue, 2)
        XCTAssertEqual(LogLevel.error.rawValue, 3)
    }

    // MARK: - Ordering

    func testSeverityOrdering() {
        // WHEN  raw values of adjacent cases are compared
        // THEN  each is strictly less than the next in severity order
        XCTAssertLessThan(LogLevel.debug.rawValue, LogLevel.info.rawValue)
        XCTAssertLessThan(LogLevel.info.rawValue, LogLevel.warning.rawValue)
        XCTAssertLessThan(LogLevel.warning.rawValue, LogLevel.error.rawValue)
    }

    func testComparableOrdering() {
        // WHEN  cases are compared using < and >=
        // THEN  ordering is consistent with severity from debug (lowest) to error (highest)
        XCTAssertTrue(LogLevel.debug < .info)
        XCTAssertTrue(LogLevel.info < .warning)
        XCTAssertTrue(LogLevel.warning < .error)

        XCTAssertTrue(LogLevel.info >= .debug)
        XCTAssertTrue(LogLevel.warning >= .info)
        XCTAssertTrue(LogLevel.error >= .warning)
        XCTAssertTrue(LogLevel.error >= .error)
    }

    // MARK: - Name & Description

    func testNameValues() {
        // WHEN  name is read for each LogLevel case
        // THEN  it returns the uppercased string representation
        XCTAssertEqual(LogLevel.debug.name, "DEBUG")
        XCTAssertEqual(LogLevel.info.name, "INFO")
        XCTAssertEqual(LogLevel.warning.name, "WARNING")
        XCTAssertEqual(LogLevel.error.name, "ERROR")
    }

    func testDescriptionEqualsName() {
        // WHEN  description is read for each LogLevel case
        // THEN  it equals the case's name property
        for level in LogLevel.allCases {
            XCTAssertEqual(level.description, level.name)
        }
    }

    // MARK: - CaseIterable

    func testAllCasesOrder() {
        // WHEN  allCases is accessed
        // THEN  cases appear in ascending severity order
        XCTAssertEqual(LogLevel.allCases, [.debug, .info, .warning, .error])
    }
}
