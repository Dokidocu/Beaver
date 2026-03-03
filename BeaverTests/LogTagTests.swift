import XCTest
@testable import Beaver

final class LogTagTests: XCTestCase {
    // MARK: - Initialization

    func testInitStoresGivenValues() {
        let tag = LogTag(
            subsystem: "com.example.app.network",
            prefix: "NET",
            name: "Network"
        )

        XCTAssertEqual(tag.subsystem, "com.example.app.network")
        XCTAssertEqual(String(describing: tag.prefix), "NET")
        XCTAssertEqual(String(describing: tag.name), "Network")
    }

    func testInitAllowsEmptyPrefix() {
        let tag = LogTag(
            subsystem: "com.example.app",
            prefix: "",
            name: "General"
        )

        XCTAssertEqual(tag.subsystem, "com.example.app")
        XCTAssertEqual(String(describing: tag.prefix), "")
        XCTAssertEqual(String(describing: tag.name), "General")
    }

    func testDifferentTagsCanHaveSameSubsystem() {
        let network = LogTag(
            subsystem: "com.example.app",
            prefix: "NET",
            name: "Network"
        )

        let auth = LogTag(
            subsystem: "com.example.app",
            prefix: "AUTH",
            name: "Auth"
        )

        XCTAssertEqual(network.subsystem, auth.subsystem)
        XCTAssertNotEqual(network, auth)
    }

    func testIdentifierWithPrefix() {
        let tag = LogTag(
            subsystem: "com.example.app.network",
            prefix: "NET",
            name: "Network"
        )

        XCTAssertEqual(tag.identifier, "NET Network")
    }

    func testIdentifierWithoutPrefix() {
        let tag = LogTag(
            subsystem: "com.example.app",
            prefix: "",
            name: "General"
        )

        XCTAssertEqual(tag.identifier, "General")
    }

    // MARK: - Equatable / Hashable

    func testEqualityWhenAllFieldsMatch() {
        let logA = LogTag(
            subsystem: "com.example.app.network",
            prefix: "NET",
            name: "Network"
        )

        let logB = LogTag(
            subsystem: "com.example.app.network",
            prefix: "NET",
            name: "Network"
        )

        XCTAssertEqual(logA, logB)
        XCTAssertEqual(logA.hashValue, logB.hashValue)
    }

    func testInequalityWhenAnyFieldDiffers() {
        let base = LogTag(
            subsystem: "com.example.app",
            prefix: "NET",
            name: "Network"
        )

        let differentSubsystem = LogTag(
            subsystem: "com.example.app.network",
            prefix: "NET",
            name: "Network"
        )

        let differentPrefix = LogTag(
            subsystem: "com.example.app",
            prefix: "AUTH",
            name: "Network"
        )

        let differentName = LogTag(
            subsystem: "com.example.app",
            prefix: "NET",
            name: "Auth"
        )

        XCTAssertNotEqual(base, differentSubsystem)
        XCTAssertNotEqual(base, differentPrefix)
        XCTAssertNotEqual(base, differentName)
    }
}
