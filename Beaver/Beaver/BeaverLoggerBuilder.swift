//
//  BeaverLoggerBuilder.swift
//  Beaver
//
//  Created by Henri La on 29.06.2025.
//

import Foundation

// MARK: - Builder Pattern

public struct BeaverLoggerBuilder {
    private var logLevel: LogLevel = .debug
    private var logSinks: [LogSink] = []

    public init() {}

    public func setLogLevel(_ logLevel: LogLevel) -> BeaverLoggerBuilder {
        var builder = self
        builder.logLevel = logLevel
        return builder
    }

    public func addLogSink(_ logSink: LogSink) -> BeaverLoggerBuilder {
        var builder = self
        builder.logSinks.append(logSink)
        return builder
    }

    public func build() -> BeaverLogger {
        return BeaverLogger(logLevel: logLevel, logSinks: logSinks)
    }
}
