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

        XCTAssertEqual(String(describing: tag.subsystem), "com.example.app.network")
        XCTAssertEqual(String(describing: tag.prefix), "NET")
        XCTAssertEqual(String(describing: tag.name), "Network")
    }

    func testInitAllowsEmptyPrefix() {
        let tag = LogTag(
            subsystem: "com.example.app",
            prefix: "",
            name: "General"
        )

        XCTAssertEqual(String(describing: tag.subsystem), "com.example.app")
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

        XCTAssertEqual(String(describing: network.subsystem), String(describing: auth.subsystem))
        XCTAssertNotEqual(
            String(describing: network.name),
            String(describing: auth.name)
        )
    }
    
    func testIdentifierWithPrefix() {
        let tag = LogTag(
            subsystem: "com.example.app.network",
            prefix: "NET",
            name: "Network"
        )

        // Only valid if you implement `identifier` as suggested above.
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

    // MARK: - Example: Equatable / Hashable (if you conform later)

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

        XCTAssertEqual(String(describing: logA), String(describing: logB))
        XCTAssertEqual(String(describing: logA).hashValue, String(describing: logB).hashValue)
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

        XCTAssertNotEqual(String(describing: base), String(describing: differentSubsystem))
        XCTAssertNotEqual(String(describing: base), String(describing: differentPrefix))
        XCTAssertNotEqual(String(describing: base), String(describing: differentName))
    }
}
