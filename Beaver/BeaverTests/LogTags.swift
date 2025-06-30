//
//  Tags.swift
//  BeaverTests
//
//  Created by Henri La on 30.06.2025.
//

import Foundation
import Beaver

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
