//
//  ConsoleLogSink.swift
//  BeaverTests
//
//  Created by Henri La on 29.06.2025.
//

import Foundation
import Beaver

public struct ConsoleLogSink: LogSink {

    public init() {}

    public func writeLog(logLevel: LogLevel, logTag: any LogTag, message: String, file: String, line: Int) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        let timestamp = dateFormatter.string(from: Date())
        let filename = URL(fileURLWithPath: file).lastPathComponent
        let logMessage = "\(timestamp) \(logTag.prefix)[\(logLevel.name)] \(filename):\(line) - \(message)"
        print(logMessage)
    }
}
