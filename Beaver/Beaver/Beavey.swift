//
//  Beaver.swift
//  Beaver
//
//  Created by Henri La on 01.07.2025.
//

public enum Beavy {
    nonisolated(unsafe) private static var defaultLogger = BeaverLoggerBuilder().build()

    public static func configure(with builder: BeaverLoggerBuilder) {
        Self.defaultLogger = builder.build()
    }

    public static func debug(tag: LogTag, message: @autoclosure () -> String) {
        Self.defaultLogger.debug(tag: tag, message: message())
    }

    public static func info(tag: LogTag, message: @autoclosure () -> String) {
        defaultLogger.info(tag: tag, message: message())
    }

    public static func warning(tag: LogTag, message: @autoclosure () -> String) {
        defaultLogger.warning(tag: tag, message: message())
    }

    public static func error(tag: LogTag, message: @autoclosure () -> String) {
        defaultLogger.error(tag: tag, message: message())
    }
}
