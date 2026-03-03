import XCTest
import Beaver

final class LogLevelTests: XCTestCase {
    // MARK: - Priority & Ordering

    func testRawValuesAndPriorityMatch() {
        XCTAssertEqual(LogLevel.debug.rawValue, 0)
        XCTAssertEqual(LogLevel.info.rawValue, 1)
        XCTAssertEqual(LogLevel.warning.rawValue, 2)
        XCTAssertEqual(LogLevel.error.rawValue, 3)

        XCTAssertEqual(LogLevel.debug.priority, 0)
        XCTAssertEqual(LogLevel.info.priority, 1)
        XCTAssertEqual(LogLevel.warning.priority, 2)
        XCTAssertEqual(LogLevel.error.priority, 3)
    }

    func testSeverityOrdering() {
        XCTAssertLessThan(LogLevel.debug.rawValue, LogLevel.info.rawValue)
        XCTAssertLessThan(LogLevel.info.rawValue, LogLevel.warning.rawValue)
        XCTAssertLessThan(LogLevel.warning.rawValue, LogLevel.error.rawValue)
    }

    func testComparableOrdering() {
        // Only valid if LogLevel: Comparable
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
        XCTAssertEqual(LogLevel.debug.name, "DEBUG")
        XCTAssertEqual(LogLevel.info.name, "INFO")
        XCTAssertEqual(LogLevel.warning.name, "WARNING")
        XCTAssertEqual(LogLevel.error.name, "ERROR")
    }

    func testDescriptionEqualsName() {
        for level in LogLevel.allCases {
            XCTAssertEqual(level.description, level.name)
        }
    }

    // MARK: - CaseIterable

    func testAllCasesOrder() {
        XCTAssertEqual(LogLevel.allCases, [.debug, .info, .warning, .error])
    }
}
