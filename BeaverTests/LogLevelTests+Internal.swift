import XCTest
import OSLog
@testable import Beaver

final class LogLevelTestsInternal: XCTestCase {
    func testOSLogTypeMapping() {
        // WHEN  osLogType is read for each LogLevel case
        // THEN  each maps to the expected OSLogType severity
        //       (warning maps to .fault, which is the closest OSLog equivalent)
        XCTAssertEqual(LogLevel.debug.osLogType, OSLogType.debug)
        XCTAssertEqual(LogLevel.info.osLogType, OSLogType.info)
        XCTAssertEqual(LogLevel.warning.osLogType, OSLogType.fault)
        XCTAssertEqual(LogLevel.error.osLogType, OSLogType.error)
    }
}
