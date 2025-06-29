import XCTest
@testable import Beaver

final class BeaverTests: XCTestCase {
    
    func testLogLevelFiltering() {
        let mockSink = MockLogSink()
        let logger = BeaverBuilder()
            .setLogLevel(.warning)
            .setLogSinks([mockSink])
            .build()
        
        let tag = TestTag()
        logger.debug(tag: tag, message: "Debug message")
        logger.info(tag: tag, message: "Info message")
        logger.warning(tag: tag, message: "Warning message")
        logger.error(tag: tag, message: "Error message")
        
        // Only warning and error should be logged
        XCTAssertEqual(mockSink.loggedMessages.count, 2)
        XCTAssertEqual(mockSink.loggedMessages[0].level, .warning)
        XCTAssertEqual(mockSink.loggedMessages[1].level, .error)
    }
    
    func testBuilderPattern() {
        let customSink = MockLogSink()
        let logger = BeaverBuilder()
            .setLogLevel(.info)
            .setLogSinks([customSink])
            .setSubsystem("com.test.beaver")
            .setCategory("TestCategory")
            .build()
        
        XCTAssertNotNil(logger)
        
        let tag = TestTag()
        logger.info(tag: tag, message: "Test message")
        
        XCTAssertEqual(customSink.loggedMessages.count, 1)
        XCTAssertEqual(customSink.loggedMessages.first?.message, "Test message")
    }
    
    func testLogTagProperties() {
        let tag = TestTag()
        XCTAssertEqual(tag.subsystem, "com.test.app")
        XCTAssertEqual(tag.prefix, "[TEST] ")
        XCTAssertEqual(tag.name, "TestTag")
    }
    
    func testLogLevelEscalation() {
        var level = LogLevel.debug
        level.escalate()
        XCTAssertEqual(level, .info)
        
        level.escalate()
        XCTAssertEqual(level, .warning)
        
        level.escalate()
        XCTAssertEqual(level, .error)
        
        level.escalate() // Should stay at error
        XCTAssertEqual(level, .error)
    }
    
    func testConsoleLogSink() {
        let consoleSink = ConsoleLogSink()
        let tag = TestTag()
        
        // This should not crash
        XCTAssertNoThrow {
            consoleSink.writeLog(
                logLevel: .info,
                logTag: tag,
                message: "Test console message",
                file: #file,
                line: #line
            )
        }
    }
    
    func testMultipleLogSinks() {
        let mockSink1 = MockLogSink()
        let mockSink2 = MockLogSink()
        
        let logger = BeaverBuilder()
            .setLogLevel(.debug)
            .setLogSinks([mockSink1, mockSink2])
            .build()
        
        let tag = TestTag()
        logger.info(tag: tag, message: "Test message")
        
        XCTAssertEqual(mockSink1.loggedMessages.count, 1)
        XCTAssertEqual(mockSink2.loggedMessages.count, 1)
        XCTAssertEqual(mockSink1.loggedMessages.first?.message, "Test message")
        XCTAssertEqual(mockSink2.loggedMessages.first?.message, "Test message")
    }
    
    func testGlobalBeaverInstance() {
        let mockSink = MockLogSink()
        
        Beaver.configure(with: BeaverBuilder()
            .setLogLevel(.info)
            .addLogSink(mockSink)
        )
        
        Beaver.info("Global info message")
        
        XCTAssertEqual(mockSink.loggedMessages.count, 1)
        XCTAssertEqual(mockSink.loggedMessages.first?.message, "Global info message")
    }
}

// MARK: - Test Helpers

class MockLogSink: LogSink {
    var loggedMessages: [(level: LogLevel, tag: String, message: String)] = []
    
    func writeLog(logLevel: LogLevel, logTag: any LogTag, message: String, file: String, line: Int) {
        loggedMessages.append((level: logLevel, tag: logTag.name, message: message))
    }
}

struct TestTag: LogTag {
    var subsystem: String = "com.test.app"
    var prefix: String = "[TEST] "
    var name: String = "TestTag"
}
