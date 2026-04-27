final class LoggerFacade: LogSink, Sendable {
    private let sink: any LogSink
    private let minimumLevel: LogLevel

    init(sink: any LogSink, minimumLevel: LogLevel) {
        self.sink = sink
        self.minimumLevel = minimumLevel
    }

    func writeLog(
        logLevel: LogLevel,
        logTag: LogTag,
        message: () -> LogMessage,
        context: LogContext
    ) {
        guard logLevel >= minimumLevel else { return }
        sink.writeLog(logLevel: logLevel, logTag: logTag, message: message(), context: context)
    }

    func writeLog(logLevel: LogLevel, logTag: LogTag, message: LogMessage, context: LogContext) {
        guard logLevel >= minimumLevel else { return }
        sink.writeLog(logLevel: logLevel, logTag: logTag, message: message, context: context)
    }
}
