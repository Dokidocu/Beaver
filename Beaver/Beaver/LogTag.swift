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

// Predefined common log tags
public struct GeneralTag: LogTag {
    public var subsystem: String
    public var prefix: String
    public var name: String
    
    public init(subsystem: String? = nil) {
        self.subsystem = subsystem ?? Bundle.main.bundleIdentifier ?? "com.app.general"
        self.name = "General"
        self.prefix = "[GENERAL] "
    }
}

public struct NetworkTag: LogTag {
    public var subsystem: String
    public var prefix: String
    public var name: String
    
    public init(subsystem: String? = nil) {
        self.subsystem = subsystem ?? Bundle.main.bundleIdentifier ?? "com.app.network"
        self.name = "Network"
        self.prefix = "[NET] "
    }
}

public struct DatabaseTag: LogTag {
    public var subsystem: String
    public var prefix: String
    public var name: String
    
    public init(subsystem: String? = nil) {
        self.subsystem = subsystem ?? Bundle.main.bundleIdentifier ?? "com.app.database"
        self.name = "Database"
        self.prefix = "[DB] "
    }
}

public struct UITag: LogTag {
    public var subsystem: String
    public var prefix: String
    public var name: String
    
    public init(subsystem: String? = nil) {
        self.subsystem = subsystem ?? Bundle.main.bundleIdentifier ?? "com.app.ui"
        self.name = "UI"
        self.prefix = "[UI] "
    }
}
