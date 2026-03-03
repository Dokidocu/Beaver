// MARK: - Beaver Advanced Examples
//
// Advanced usage patterns: domain-specific wrappers, multi-sink pipelines,
// structured event logging, and performance tracing.
//
// All examples compile against the actual Beaver API.

import Beaver
import Foundation

// ─── 1. Domain-specific log tags ─────────────────────────────────────────────

private enum AppTags {
    private static let bundle = Bundle.main.bundleIdentifier ?? "com.example.app"

    static let user      = LogTag(subsystem: "\(bundle).user",      prefix: "👤", name: "User")
    static let cart      = LogTag(subsystem: "\(bundle).cart",      prefix: "🛒", name: "Cart")
    static let orders    = LogTag(subsystem: "\(bundle).orders",    prefix: "📦", name: "Orders")
    static let payments  = LogTag(subsystem: "\(bundle).payments",  prefix: "💳", name: "Payments")
    static let inventory = LogTag(subsystem: "\(bundle).inventory", prefix: "📋", name: "Inventory")
}

// ─── 2. Domain logger façade ──────────────────────────────────────────────────
//
// Wrap Log in a domain-specific type to pin the tag and expose
// method names that match your domain vocabulary. No stored logger reference
// is needed — all calls delegate to the shared instance.

struct OrderLogger {
    func created(orderId: String, userId: String) {
        Log.info("Order created — id: \(orderId), user: \(userId)", tag: AppTags.orders)
    }

    func fulfilled(orderId: String) {
        Log.info("Order fulfilled — id: \(orderId)", tag: AppTags.orders)
    }

    func cancelled(orderId: String, reason: String) {
        Log.warning("Order cancelled — id: \(orderId), reason: \(reason)", tag: AppTags.orders)
    }

    func paymentFailed(orderId: String, error: Error) {
        Log.error("Payment failed — id: \(orderId), error: \(error)", tag: AppTags.payments)
    }
}

// ─── 3. API client with structured request logging ───────────────────────────

struct APIResponse: Codable {
    let statusCode: Int
    let path: String
    let durationMs: Double
}

final class APIClient {
    func fetch<T: Decodable>(path: String, as type: T.Type) async throws -> T {
        Log.debug("→ GET \(path)", tag: LogTags.api)

        let start = Date()
        let url = URL(string: "https://api.example.com\(path)")!

        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            let ms = Date().timeIntervalSince(start) * 1_000
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0

            let meta = APIResponse(statusCode: statusCode, path: path, durationMs: ms)
            Log.debug("← \(statusCode) \(path) in \(ms, precision: 1) ms\n\(json: meta)", tag: LogTags.api)

            if statusCode >= 400 {
                Log.warning("\(statusCode) response from \(path)", tag: LogTags.api)
            }

            return try JSONDecoder().decode(type, from: data)

        } catch {
            let ms = Date().timeIntervalSince(start) * 1_000
            Log.error("Request to \(path) failed after \(ms, precision: 1) ms: \(error)", tag: LogTags.network)
            throw error
        }
    }
}

// ─── 4. Performance tracing ───────────────────────────────────────────────────

struct Trace {
    let label: String
    private let start = Date()

    func finish() {
        let ms = Date().timeIntervalSince(start) * 1_000
        Log.debug("\(label) finished in \(ms, precision: 2) ms", tag: LogTags.performance)
    }
}

func expensiveWork() async {
    let trace = Trace(label: "expensiveWork")
    // … do work …
    trace.finish()
}

// ─── 5. Multi-sink pipeline ──────────────────────────────────────────────────
//
// Route all logs to OSLog in development; add a remote sink for warnings and
// above in production without changing call sites.

final class WarningsAndAboveSink: LogSink, @unchecked Sendable {
    private let inner: any LogSink
    private let queue = DispatchQueue(label: "com.example.warnings-sink", qos: .utility)

    init(inner: any LogSink) {
        self.inner = inner
    }

    func writeLog(
        logLevel: LogLevel,
        logTag: LogTag,
        message: LogMessage,
        context: LogContext
    ) {
        guard logLevel >= .warning else { return }
        // Capture before async hop
        let level = logLevel
        let tag = logTag
        let msg = message
        let ctx = context
        queue.async { self.inner.writeLog(logLevel: level, logTag: tag, message: msg, context: ctx) }
    }
}

func configureProductionPipeline(remoteSink: any LogSink) async {
    await Log.configure(.init(
        minimumLevel: .debug,
        sinks: [
            OSLogSink(),
            WarningsAndAboveSink(inner: remoteSink)
        ]
    ))
}

// ─── 6. Structured event sink ─────────────────────────────────────────────────
//
// Demonstrate a sink that converts log entries to structured JSON events
// suitable for a log aggregation service.

struct LogEvent: Encodable {
    let timestamp: String
    let level: String
    let subsystem: String
    let category: String
    let file: String
    let function: String
    let line: UInt
    let message: String
}

final class StructuredJSONSink: LogSink, @unchecked Sendable {
    private let encoder: JSONEncoder = {
        let e = JSONEncoder()
        e.outputFormatting = .sortedKeys
        return e
    }()

    private let formatter: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return f
    }()

    func writeLog(
        logLevel: LogLevel,
        logTag: LogTag,
        message: LogMessage,
        context: LogContext
    ) {
        let file = String(describing: context.file).split(separator: "/").last.map(String.init) ?? ""
        let event = LogEvent(
            timestamp: formatter.string(from: Date()),
            level: logLevel.rawValue,
            subsystem: logTag.subsystem,
            category: String(describing: logTag.name),
            file: file,
            function: String(describing: context.function),
            line: context.line,
            message: message.value
        )
        if let data = try? encoder.encode(event),
           let json = String(data: data, encoding: .utf8) {
            print(json)  // replace with actual I/O
        }
    }
}
