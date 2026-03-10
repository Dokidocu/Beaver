import XCTest
import Beaver

final class LogTagTests: XCTestCase {
    // MARK: - Initialization

    func testInitStoresGivenValues() {
        // GIVEN a LogTag created with explicit subsystem, prefix, and name
        let tag = LogTag(
            subsystem: "com.example.app.network",
            prefix: "NET",
            name: "Network"
        )

        // WHEN  its stored properties are read
        // THEN  each value matches what was passed at construction
        XCTAssertEqual(tag.subsystem, "com.example.app.network")
        XCTAssertEqual(String(describing: tag.prefix), "NET")
        XCTAssertEqual(String(describing: tag.name), "Network")
    }

    func testInitAllowsEmptyPrefix() {
        // GIVEN a LogTag created with an empty prefix
        let tag = LogTag(
            subsystem: "com.example.app",
            prefix: "",
            name: "General"
        )

        // WHEN  its stored properties are read
        // THEN  the prefix is empty and other values are stored correctly
        XCTAssertEqual(tag.subsystem, "com.example.app")
        XCTAssertEqual(String(describing: tag.prefix), "")
        XCTAssertEqual(String(describing: tag.name), "General")
    }

    func testDifferentTagsCanHaveSameSubsystem() {
        // GIVEN two LogTags sharing the same subsystem but different prefixes and names
        let network = LogTag(subsystem: "com.example.app", prefix: "NET", name: "Network")
        let auth = LogTag(subsystem: "com.example.app", prefix: "AUTH", name: "Auth")

        // WHEN  their subsystems and equality are compared
        // THEN  subsystems are equal but the tags themselves are not
        XCTAssertEqual(network.subsystem, auth.subsystem)
        XCTAssertNotEqual(network, auth)
    }

    // MARK: - Identifier

    func testIdentifierWithPrefix() {
        // GIVEN a LogTag with prefix "NET" and name "Network"
        let tag = LogTag(subsystem: "com.example.app.network", prefix: "NET", name: "Network")

        // WHEN  identifier is read
        // THEN  it equals "NET Network"
        XCTAssertEqual(tag.identifier, "NET Network")
    }

    func testIdentifierWithoutPrefix() {
        // GIVEN a LogTag with an empty prefix and name "General"
        let tag = LogTag(subsystem: "com.example.app", prefix: "", name: "General")

        // WHEN  identifier is read
        // THEN  it equals just the name "General"
        XCTAssertEqual(tag.identifier, "General")
    }

    // MARK: - Equatable / Hashable

    func testEqualityWhenAllFieldsMatch() {
        // GIVEN two LogTags created with identical subsystem, prefix, and name
        let logA = LogTag(subsystem: "com.example.app.network", prefix: "NET", name: "Network")
        let logB = LogTag(subsystem: "com.example.app.network", prefix: "NET", name: "Network")

        // WHEN  compared with ==
        // THEN  they are equal and share the same hash value
        XCTAssertEqual(logA, logB)
        XCTAssertEqual(logA.hashValue, logB.hashValue)
    }

    func testInequalityWhenAnyFieldDiffers() {
        // GIVEN a base LogTag and three variants each differing in exactly one field
        let base = LogTag(subsystem: "com.example.app", prefix: "NET", name: "Network")
        let differentSubsystem = LogTag(subsystem: "com.example.app.network", prefix: "NET", name: "Network")
        let differentPrefix = LogTag(subsystem: "com.example.app", prefix: "AUTH", name: "Network")
        let differentName = LogTag(subsystem: "com.example.app", prefix: "NET", name: "Auth")

        // WHEN  each variant is compared to the base
        // THEN  none of them are equal to the base
        XCTAssertNotEqual(base, differentSubsystem)
        XCTAssertNotEqual(base, differentPrefix)
        XCTAssertNotEqual(base, differentName)
    }
}
