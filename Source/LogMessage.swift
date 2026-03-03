//
//  File.swift
//  Beaver
//
//  Created by Henri La on 07.02.2026.
//

import Foundation

public struct LogMessage: Sendable, ExpressibleByStringInterpolation {
    public let value: String

    // MARK: - Literal

    public init(stringLiteral value: String) {
        self.value = value
    }

    // MARK: - Interpolation

    public init(stringInterpolation: StringInterpolation) {
        self.value = stringInterpolation.output
    }

    public struct StringInterpolation: StringInterpolationProtocol {
        public typealias StringLiteralType = String
        var output = ""

        public init(literalCapacity: Int, interpolationCount: Int) {
            output.reserveCapacity(literalCapacity)
        }

        // MARK: - String

        public mutating func appendLiteral(_ literal: String) {
            output.append(literal)
        }

        // MARK: - Int

        public mutating func appendInterpolation(_ value: Int) {
            output.append(String(value))
        }

        // MARK: - Double

        public mutating func appendInterpolation(_ value: Double, precision: Int = 2) {
            output.append(String(format: "%.\(precision)f", value))
        }

        // MARK: - Array

        public mutating func appendInterpolation<T>(
            _ array: [T],
            separator: String = ", "
        ) {
            let content = array
                    .map { element -> String in
                        if let string = element as? String {
                            // Don’t add quotes for Strings in arrays (nicer logs)
                            return string
                        } else {
                            return String(describing: element)
                        }
                    }
                    .joined(separator: separator)
            output.append("[\(content)]")
        }

        // MARK: - Dictionary

        public mutating func appendInterpolation<K, V>(_ dict: [K: V], separator: String = ", ") {
            let content = dict
                .map { "\($0.key): \($0.value)" }
                .joined(separator: separator)

            output.append("{\(content)}")
        }

        public mutating func appendInterpolation(json dictionary: [String: Any], pretty: Bool = true) {
            guard JSONSerialization.isValidJSONObject(dictionary),
                  let data = try? JSONSerialization.data(
                    withJSONObject: dictionary,
                    options: pretty ? [.prettyPrinted, .sortedKeys] : [.sortedKeys]
                  ),
                  let json = String(data: data, encoding: .utf8)
            else {
                output.append(String(describing: dictionary))
                return
            }
            output.append(json)
        }

        public mutating func appendInterpolation(
            json dictionary: [String: Any]?
        ) {
            guard let dictionary else {
                output.append("nil")
                return
            }
            appendInterpolation(json: dictionary, pretty: true)
        }

        // MARK: - Codable

        public mutating func appendInterpolation<T: Encodable>(
            json value: T,
            pretty: Bool = true
        ) {
            let encoder = JSONEncoder()
            if pretty {
                encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            }

            guard let data = try? encoder.encode(value),
                  let json = String(data: data, encoding: .utf8)
            else {
                output.append(String(describing: value))
                return
            }

            output.append(json)
        }

        // MARK: - Optional

        public mutating func appendInterpolation<T>(_ value: T?) {
            if let value {
                output.append(String(describing: value))
            } else {
                output.append("nil")
            }
        }
    }
}
