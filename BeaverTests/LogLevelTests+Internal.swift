import XCTest
import OSLog
@testable import Beaver

final class LogLevelTestsInternal: XCTestCase {
    func testOSLogTypeMapping() {
        XCTAssertEqual(LogLevel.debug.osLogType, OSLogType.debug)
        XCTAssertEqual(LogLevel.info.osLogType, OSLogType.info)
        XCTAssertEqual(LogLevel.warning.osLogType, OSLogType.default)
        XCTAssertEqual(LogLevel.error.osLogType, OSLogType.error)
    }
}
