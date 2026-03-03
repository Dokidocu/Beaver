import XCTest
import Foundation
import Beaver

final class LogMessageTests: XCTestCase {
    // MARK: - String literal & basic interpolation

    func testStringLiteralInitialization() {
        let message: LogMessage = "Hello world"
        XCTAssertEqual(message.value, "Hello world")
    }

    func testStringInterpolationWithString() {
        let name = "World"
        let message: LogMessage = "Hello \(name)"
        XCTAssertEqual(message.value, "Hello World")
    }

    // MARK: - Int

    func testStringInterpolationWithInt() {
        let value = 42
        let message: LogMessage = "Value: \(value)"
        XCTAssertEqual(message.value, "Value: 42")
    }

    // MARK: - Double with precision

    func testDoubleInterpolationWithDefaultPrecision() {
        let value = 3.14159
        let message: LogMessage = "Pi ≈ \(value)"
        XCTAssertEqual(message.value, "Pi ≈ 3.14")
    }

    func testDoubleInterpolationWithCustomPrecision() {
        let value = 3.14159
        let message: LogMessage = "Pi ≈ \(value, precision: 3)"
        XCTAssertEqual(message.value, "Pi ≈ 3.142")
    }

    // MARK: - Array interpolation

    func testArrayInterpolation() {
        let array = [1, 2, 3]
        let message: LogMessage = "Array: \(array)"
        XCTAssertEqual(message.value, "Array: [1, 2, 3]")
    }

    func testArrayInterpolationWithStrings() {
        let array = ["a", "b", "c"]
        let message: LogMessage = "Letters: \(array)"
        XCTAssertEqual(message.value, "Letters: [a, b, c]")
    }

    // MARK: - Dictionary interpolation (non-JSON)

    func testDictionaryInterpolation() {
        let dict = ["a": 1, "b": 2]
        let message: LogMessage = "Dict: \(dict)"

        // We can't rely on key order from Dictionary.map,
        // so just check structure and contents:
        XCTAssertTrue(message.value.hasPrefix("Dict: {"))
        XCTAssertTrue(message.value.hasSuffix("}"))
        XCTAssertTrue(message.value.contains("a: 1"))
        XCTAssertTrue(message.value.contains("b: 2"))
    }

    // MARK: - Optional interpolation

    func testOptionalInterpolationSome() {
        let value: Int? = 500
        let message: LogMessage = "Optional: \(value)"
        XCTAssertEqual(message.value, "Optional: 500")
    }

    func testOptionalInterpolationNil() {
        let value: Int? = nil
        let message: LogMessage = "Optional: \(value)"
        XCTAssertEqual(message.value, "Optional: nil")
    }

    // MARK: - JSON Dictionary interpolation

    func testJSONDictionaryInterpolationPretty() throws {
        let dict: [String: Any] = [
            "b": 2,
            "a": 1
        ]

        let message: LogMessage = "JSON:\n\(json: dict)"

        // Build expected JSON string the same way as the implementation
        let data = try JSONSerialization.data(
            withJSONObject: dict,
            options: [.prettyPrinted, .sortedKeys]
        )
        let expectedJSON = String(data: data, encoding: .utf8)!

        XCTAssertEqual(message.value, "JSON:\n" + expectedJSON)
    }

    func testJSONDictionaryInterpolationNil() {
        let dict: [String: Any]? = nil
        let message: LogMessage = "JSON optional:\n\(json: dict)"

        XCTAssertEqual(message.value, "JSON optional:\nnil")
    }

    // MARK: - Codable JSON interpolation

    struct TestPayload: Codable, Equatable {
        let id: Int
        let name: String
        let tags: [String]
    }

    func testCodableJSONInterpolationPretty() throws {
        let payload = TestPayload(id: 1, name: "Test", tags: ["a", "b"])

        let message: LogMessage = "Payload:\n\(json: payload)"

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(payload)
        let expectedJSON = String(data: data, encoding: .utf8)!

        XCTAssertEqual(message.value, "Payload:\n" + expectedJSON)
    }

    // MARK: - Generic Any interpolation

    func testGenericAnyInterpolationWithCustomType() {
        struct CustomType: CustomStringConvertible {
            let value: Int
            var description: String { "CustomType(value: \(value))" }
        }

        let custom = CustomType(value: 99)
        let message: LogMessage = "Custom: \(custom)"

        XCTAssertEqual(message.value, "Custom: CustomType(value: 99)")
    }

    // MARK: - Combined / smoke test

    func testCombinedInterpolation() throws {
        struct User: Codable {
            let id: Int
            let name: String
        }

        let user = User(id: 42, name: "Jojo")
        let roles = ["admin", "beta"]
        let meta: [String: Any] = ["requestId": "abc", "attempt": 2]

        let message: LogMessage = """
        User \(user), roles \(roles), meta \(meta), pi ~ \(3.14159, precision: 3)
        """

        XCTAssertTrue(message.value.contains("User User(id: 42, name: \"Jojo\")"))
        XCTAssertTrue(message.value.contains("roles [admin, beta]"))
        XCTAssertTrue(message.value.contains("meta {"))
        XCTAssertTrue(message.value.contains("pi ~ 3.142"))
    }
}
