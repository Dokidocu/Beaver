struct LogSinks: LogSink {
    private let sinks: [any LogSink]

    init(_ sinks: [any LogSink]) {
        self.sinks = sinks
    }

    func writeLog(
        logLevel: LogLevel,
        logTag: LogTag,
        message: LogMessage,
        context: LogContext
    ) {
        for sink in sinks {
            sink.writeLog(
                logLevel: logLevel,
                logTag: logTag,
                message: message,
                context: context
            )
        }
    }
}
