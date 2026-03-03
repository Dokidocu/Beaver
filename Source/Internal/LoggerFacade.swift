final class LoggerFacade: LoggerProtocol {
    static let shared = LoggerFacade(
        sink: OSLogSink(), // default: only OSLog
        minimumLevel: .debug
    )

    private let sink: any LogSink
    private let minimumLevel: LogLevel

    init(
        sink: any LogSink,
        minimumLevel: LogLevel
    ) {
        self.sink = sink
        self.minimumLevel = minimumLevel
    }

    // MARK: - Core log

    func writeLog(logLevel: LogLevel, logTag: LogTag, message: LogMessage, context: LogContext) {
        guard logLevel.priority >= minimumLevel.priority else { return }

        sink.writeLog(logLevel: logLevel, logTag: logTag, message: message, context: context)
    }

    // MARK: - Convenience helpers

    func debug(
        _ message: LogMessage,
        tag: LogTag,
        file: StaticString = #fileID,
        function: StaticString = #function,
        line: UInt = #line
    ) {
        writeLog(
            logLevel: .debug,
            logTag: tag,
            message: message,
            context: LogContext(file: file, function: function, line: line)
        )
    }

    func info(
        _ message: LogMessage,
        tag: LogTag,
        file: StaticString = #fileID,
        function: StaticString = #function,
        line: UInt = #line
    ) {
        writeLog(
            logLevel: .info,
            logTag: tag,
            message: message,
            context: LogContext(file: file, function: function, line: line)
        )
    }

    func warning(
        _ message: LogMessage,
        tag: LogTag,
        file: StaticString = #fileID,
        function: StaticString = #function,
        line: UInt = #line
    ) {
        writeLog(
            logLevel: .warning,
            logTag: tag,
            message: message,
            context: LogContext(file: file, function: function, line: line)
        )
    }

    func error(
        _ message: LogMessage,
        tag: LogTag,
        file: StaticString = #fileID,
        function: StaticString = #function,
        line: UInt = #line
    ) {
        writeLog(
            logLevel: .error,
            logTag: tag,
            message: message,
            context: LogContext(file: file, function: function, line: line)
        )
    }
}
