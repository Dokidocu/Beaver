import XCTest
import Foundation
import Beaver

final class LogMessageTests: XCTestCase {
    // MARK: - String literal & basic interpolation

    func testStringLiteralInitialization() {
        // GIVEN a LogMessage created from a string literal
        // WHEN  value is read
        // THEN  it equals the literal string
        let message: LogMessage = "Hello world"
        XCTAssertEqual(message.value, "Hello world")
    }

    func testStringInterpolationWithString() {
        // GIVEN a String variable interpolated into a LogMessage
        let name = "World"

        // WHEN  value is read
        // THEN  the interpolated variable is expanded inline
        let message: LogMessage = "Hello \(name)"
        XCTAssertEqual(message.value, "Hello World")
    }

    // MARK: - Int

    func testStringInterpolationWithInt() {
        // GIVEN an Int variable interpolated into a LogMessage
        let value = 42

        // WHEN  value is read
        // THEN  the integer is rendered as a decimal string
        let message: LogMessage = "Value: \(value)"
        XCTAssertEqual(message.value, "Value: 42")
    }

    // MARK: - Double with precision

    func testDoubleInterpolationWithDefaultPrecision() {
        // GIVEN a Double interpolated without an explicit precision argument
        let value = 3.14159

        // WHEN  value is read
        // THEN  the number is rounded to 2 decimal places (the default)
        let message: LogMessage = "Pi ≈ \(value)"
        XCTAssertEqual(message.value, "Pi ≈ 3.14")
    }

    func testDoubleInterpolationWithCustomPrecision() {
        // GIVEN a Double interpolated with precision: 3
        let value = 3.14159

        // WHEN  value is read
        // THEN  the number is rounded to exactly 3 decimal places
        let message: LogMessage = "Pi ≈ \(value, precision: 3)"
        XCTAssertEqual(message.value, "Pi ≈ 3.142")
    }

    // MARK: - Array interpolation

    func testArrayInterpolation() {
        // GIVEN an Int array interpolated into a LogMessage
        let array = [1, 2, 3]

        // WHEN  value is read
        // THEN  elements are joined with ", " inside square brackets
        let message: LogMessage = "Array: \(array)"
        XCTAssertEqual(message.value, "Array: [1, 2, 3]")
    }

    func testArrayInterpolationWithStrings() {
        // GIVEN a String array interpolated into a LogMessage
        let array = ["a", "b", "c"]

        // WHEN  value is read
        // THEN  string elements are rendered without extra quotes
        let message: LogMessage = "Letters: \(array)"
        XCTAssertEqual(message.value, "Letters: [a, b, c]")
    }

    // MARK: - Dictionary interpolation (non-JSON)

    func testDictionaryInterpolation() {
        // GIVEN a [String: Int] dictionary interpolated into a LogMessage
        let dict = ["a": 1, "b": 2]

        // WHEN  value is read
        // THEN  entries are rendered in {key: value} format (order is not guaranteed)
        let message: LogMessage = "Dict: \(dict)"
        XCTAssertTrue(message.value.hasPrefix("Dict: {"))
        XCTAssertTrue(message.value.hasSuffix("}"))
        XCTAssertTrue(message.value.contains("a: 1"))
        XCTAssertTrue(message.value.contains("b: 2"))
    }

    // MARK: - Optional interpolation

    func testOptionalInterpolationSome() {
        // GIVEN an Optional<Int> holding a value
        let value: Int? = 500

        // WHEN  value is read
        // THEN  the unwrapped integer is rendered
        let message: LogMessage = "Optional: \(value)"
        XCTAssertEqual(message.value, "Optional: 500")
    }

    func testOptionalInterpolationNil() {
        // GIVEN an Optional<Int> holding nil
        let value: Int? = nil

        // WHEN  value is read
        // THEN  the string "nil" is rendered
        let message: LogMessage = "Optional: \(value)"
        XCTAssertEqual(message.value, "Optional: nil")
    }

    // MARK: - JSON Dictionary interpolation

    func testJSONDictionaryInterpolationPretty() throws {
        // GIVEN a [String: Any] dictionary interpolated with the json: label
        let dict: [String: Any] = ["b": 2, "a": 1]

        // WHEN  value is read
        // THEN  it matches a pretty-printed, sorted-keys JSON string
        let message: LogMessage = "JSON:\n\(json: dict)"
        let data = try JSONSerialization.data(withJSONObject: dict, options: [.prettyPrinted, .sortedKeys])
        let expectedJSON = String(data: data, encoding: .utf8)!
        XCTAssertEqual(message.value, "JSON:\n" + expectedJSON)
    }

    func testJSONDictionaryInterpolationNil() {
        // GIVEN an Optional [String: Any]? holding nil, interpolated with the json: label
        let dict: [String: Any]? = nil

        // WHEN  value is read
        // THEN  the string "nil" is rendered
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
        // GIVEN a Codable value interpolated with the json: label
        let payload = TestPayload(id: 1, name: "Test", tags: ["a", "b"])

        // WHEN  value is read
        // THEN  it matches a pretty-printed, sorted-keys JSON encoding of the value
        let message: LogMessage = "Payload:\n\(json: payload)"
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(payload)
        let expectedJSON = String(data: data, encoding: .utf8)!
        XCTAssertEqual(message.value, "Payload:\n" + expectedJSON)
    }

    // MARK: - Generic Any interpolation

    func testGenericAnyInterpolationWithCustomType() {
        // GIVEN a CustomStringConvertible type interpolated into a LogMessage
        struct CustomType: CustomStringConvertible {
            let value: Int
            var description: String { "CustomType(value: \(value))" }
        }
        let custom = CustomType(value: 99)

        // WHEN  value is read
        // THEN  the type's description is rendered inline
        let message: LogMessage = "Custom: \(custom)"
        XCTAssertEqual(message.value, "Custom: CustomType(value: 99)")
    }

    // MARK: - Combined smoke test

    func testCombinedInterpolation() throws {
        // GIVEN a message combining a Codable struct, a String array, a [String: Any] dict, and a Double
        struct User: Codable {
            let id: Int
            let name: String
        }
        let user = User(id: 42, name: "Jojo")
        let roles = ["admin", "beta"]
        let meta: [String: Any] = ["requestId": "abc", "attempt": 2]

        // WHEN  value is read
        // THEN  each interpolated segment appears correctly in the output
        let message: LogMessage = """
        User \(user), roles \(roles), meta \(meta), pi ~ \(3.14159, precision: 3)
        """
        XCTAssertTrue(message.value.contains("User User(id: 42, name: \"Jojo\")"))
        XCTAssertTrue(message.value.contains("roles [admin, beta]"))
        XCTAssertTrue(message.value.contains("meta {"))
        XCTAssertTrue(message.value.contains("pi ~ 3.142"))
    }
}
