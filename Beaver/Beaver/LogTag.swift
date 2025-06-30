import Foundation

public protocol LogTag: Sendable {
    var subsystem: String { get }
    var prefix: String { get }
    var name: String { get }
}

// Default implementations for common use cases
extension LogTag {
    public var subsystem: String {
        return Bundle.main.bundleIdentifier ?? "com.app.unknown"
    }
    
    public var prefix: String {
        return "[\(name.uppercased())] "
    }
}
