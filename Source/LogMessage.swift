import Foundation

public struct LogMessage: Sendable, ExpressibleByStringInterpolation {
    public let value: String
    let components: [Component]

    enum Privacy: Sendable, Equatable {
        case inherited
        case `private`
        case `public`
    }

    enum Component: Sendable, Equatable {
        case literal(String)
        case interpolation(String, privacy: Privacy)
    }

    // MARK: - Literal

    public init(stringLiteral value: String) {
        self.value = value
        components = [.literal(value)]
    }

    // MARK: - Interpolation

    public init(stringInterpolation: StringInterpolation) {
        self.value = stringInterpolation.output
        components = stringInterpolation.components
    }

    func renderedValue(defaultPrivacy: Privacy) -> String {
        components.reduce(into: "") { result, component in
            switch component {
            case let .literal(text):
                result.append(text)
            case let .interpolation(text, privacy):
                switch privacy {
                case .public:
                    result.append(text)
                case .private:
                    result.append("<private>")
                case .inherited:
                    result.append(defaultPrivacy == .private ? "<private>" : text)
                }
            }
        }
    }

    public struct StringInterpolation: StringInterpolationProtocol {
        public typealias StringLiteralType = String
        var output = ""
        var components: [Component] = []

        public init(literalCapacity: Int, interpolationCount: Int) {
            output.reserveCapacity(literalCapacity)
            components.reserveCapacity(literalCapacity + interpolationCount)
        }

        // MARK: - String

        public mutating func appendLiteral(_ literal: String) {
            output.append(literal)
            components.append(.literal(literal))
        }

        // MARK: - Int

        public mutating func appendInterpolation(_ value: Int) {
            appendRenderedInterpolation(String(value))
        }

        // MARK: - Double

        public mutating func appendInterpolation(_ value: Double, precision: Int = 2) {
            appendRenderedInterpolation(String(format: "%.\(precision)f", value))
        }

        public mutating func appendInterpolation(private value: Int) {
            appendRenderedInterpolation(String(value), privacy: .private)
        }

        public mutating func appendInterpolation(public value: Int) {
            appendRenderedInterpolation(String(value), privacy: .public)
        }

        public mutating func appendInterpolation(private value: Double, precision: Int = 2) {
            appendRenderedInterpolation(
                String(format: "%.\(precision)f", value),
                privacy: .private
            )
        }

        public mutating func appendInterpolation(public value: Double, precision: Int = 2) {
            appendRenderedInterpolation(
                String(format: "%.\(precision)f", value),
                privacy: .public
            )
        }

        // MARK: - Array

        public mutating func appendInterpolation<T>(
            _ array: [T],
            separator: String = ", "
        ) {
            appendRenderedInterpolation(renderedArray(array, separator: separator))
        }

        public mutating func appendInterpolation<T>(
            private array: [T],
            separator: String = ", "
        ) {
            appendRenderedInterpolation(
                renderedArray(array, separator: separator),
                privacy: .private
            )
        }

        public mutating func appendInterpolation<T>(
            public array: [T],
            separator: String = ", "
        ) {
            appendRenderedInterpolation(
                renderedArray(array, separator: separator),
                privacy: .public
            )
        }

        // MARK: - Dictionary

        public mutating func appendInterpolation<K, V>(_ dict: [K: V], separator: String = ", ") {
            appendRenderedInterpolation(renderedDictionary(dict, separator: separator))
        }

        public mutating func appendInterpolation<K, V>(
            private dict: [K: V],
            separator: String = ", "
        ) {
            appendRenderedInterpolation(
                renderedDictionary(dict, separator: separator),
                privacy: .private
            )
        }

        public mutating func appendInterpolation<K, V>(
            public dict: [K: V],
            separator: String = ", "
        ) {
            appendRenderedInterpolation(
                renderedDictionary(dict, separator: separator),
                privacy: .public
            )
        }

        public mutating func appendInterpolation(json dictionary: [String: Any], pretty: Bool = true) {
            appendRenderedInterpolation(renderedJSON(dictionary: dictionary, pretty: pretty))
        }

        public mutating func appendInterpolation(
            json dictionary: [String: Any]?
        ) {
            guard let dictionary else {
                appendRenderedInterpolation("nil")
                return
            }
            appendInterpolation(json: dictionary, pretty: true)
        }

        public mutating func appendInterpolation(
            privateJSON dictionary: [String: Any],
            pretty: Bool = true
        ) {
            appendRenderedInterpolation(
                renderedJSON(dictionary: dictionary, pretty: pretty),
                privacy: .private
            )
        }

        public mutating func appendInterpolation(
            publicJSON dictionary: [String: Any],
            pretty: Bool = true
        ) {
            appendRenderedInterpolation(
                renderedJSON(dictionary: dictionary, pretty: pretty),
                privacy: .public
            )
        }

        public mutating func appendInterpolation(
            privateJSON dictionary: [String: Any]?
        ) {
            guard let dictionary else {
                appendRenderedInterpolation("nil", privacy: .private)
                return
            }
            appendInterpolation(privateJSON: dictionary, pretty: true)
        }

        public mutating func appendInterpolation(
            publicJSON dictionary: [String: Any]?
        ) {
            guard let dictionary else {
                appendRenderedInterpolation("nil", privacy: .public)
                return
            }
            appendInterpolation(publicJSON: dictionary, pretty: true)
        }

        // MARK: - Codable

        public mutating func appendInterpolation<T: Encodable>(
            json value: T,
            pretty: Bool = true
        ) {
            appendRenderedInterpolation(renderedJSON(encodable: value, pretty: pretty))
        }

        public mutating func appendInterpolation<T: Encodable>(
            privateJSON value: T,
            pretty: Bool = true
        ) {
            appendRenderedInterpolation(
                renderedJSON(encodable: value, pretty: pretty),
                privacy: .private
            )
        }

        public mutating func appendInterpolation<T: Encodable>(
            publicJSON value: T,
            pretty: Bool = true
        ) {
            appendRenderedInterpolation(
                renderedJSON(encodable: value, pretty: pretty),
                privacy: .public
            )
        }

        // MARK: - Optional

        public mutating func appendInterpolation<T>(_ value: T?) {
            if let value {
                appendRenderedInterpolation(String(describing: value))
            } else {
                appendRenderedInterpolation("nil")
            }
        }

        public mutating func appendInterpolation<T>(private value: T?) {
            if let value {
                appendRenderedInterpolation(String(describing: value), privacy: .private)
            } else {
                appendRenderedInterpolation("nil", privacy: .private)
            }
        }

        public mutating func appendInterpolation<T>(public value: T?) {
            if let value {
                appendRenderedInterpolation(String(describing: value), privacy: .public)
            } else {
                appendRenderedInterpolation("nil", privacy: .public)
            }
        }

        // MARK: - Generic

        public mutating func appendInterpolation<T>(private value: T) {
            appendRenderedInterpolation(String(describing: value), privacy: .private)
        }

        public mutating func appendInterpolation<T>(public value: T) {
            appendRenderedInterpolation(String(describing: value), privacy: .public)
        }

        // MARK: - Helpers

        private mutating func appendRenderedInterpolation(
            _ rendered: String,
            privacy: Privacy = .inherited
        ) {
            output.append(rendered)
            components.append(.interpolation(rendered, privacy: privacy))
        }

        private func renderedArray<T>(_ array: [T], separator: String) -> String {
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
            return "[\(content)]"
        }

        private func renderedDictionary<K, V>(
            _ dict: [K: V],
            separator: String
        ) -> String {
            let content = dict
                .map { key, value in
                    let displayedKey = String(describing: key)
                    let renderedPair = "\(displayedKey): \(String(describing: value))"
                    return (displayedKey: displayedKey, renderedPair: renderedPair)
                }
                .sorted {
                    if $0.displayedKey == $1.displayedKey {
                        return $0.renderedPair < $1.renderedPair
                    }
                    return $0.displayedKey < $1.displayedKey
                }
                .map(\.renderedPair)
                .joined(separator: separator)

            return "{\(content)}"
        }

        private func renderedJSON(dictionary: [String: Any], pretty: Bool) -> String {
            guard JSONSerialization.isValidJSONObject(dictionary),
                  let data = try? JSONSerialization.data(
                    withJSONObject: dictionary,
                    options: pretty ? [.prettyPrinted, .sortedKeys] : [.sortedKeys]
                  ),
                  let json = String(data: data, encoding: .utf8)
            else {
                return String(describing: dictionary)
            }
            return json
        }

        private func renderedJSON<T: Encodable>(encodable value: T, pretty: Bool) -> String {
            let encoder = JSONEncoder()
            if pretty {
                encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            }

            guard let data = try? encoder.encode(value),
                  let json = String(data: data, encoding: .utf8)
            else {
                return String(describing: value)
            }

            return json
        }
    }
}
