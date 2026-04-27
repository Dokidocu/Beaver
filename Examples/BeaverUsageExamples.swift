// MARK: - Beaver Usage Examples
//
// This file demonstrates real-world usage patterns for the Beaver logging framework.
// All examples compile against the actual Beaver API.

import Beaver
import Combine
import Foundation

// ─── 1. App startup ──────────────────────────────────────────────────────────
//
// Configure once, early in the app lifecycle. Every log call after this point
// uses the new pipeline. `configure` is the only async call; everything else is
// synchronous and can be called from any thread or actor.

func configureLogging() async {
    await Log.configure(.init(
        minimumLevel: .debug,
        sinks: [OSLogSink()]
    ))
}

// ─── 2. Basic logging — static convenience ───────────────────────────────────
//
// The cleanest way to log. No reference to the shared instance needed.

func basicLogging() {
    Log.debug("App is starting up")
    Log.info("User authenticated successfully", tag: LogTags.auth)
    Log.warning("Response time exceeded threshold", tag: LogTags.network)
    Log.error("Failed to save user preferences", tag: LogTags.general)
}

// ─── 3. Logging from a @MainActor type ───────────────────────────────────────
//
// All log methods are nonisolated — no await, no Task.detached, no DispatchQueue.

@MainActor
final class HomeViewModel: ObservableObject {
    @Published private(set) var isLoading = false

    func loadDashboard() async {
        isLoading = true
        Log.info("Dashboard loading started", tag: LogTags.lifecycle)

        // … perform async work …

        isLoading = false
        Log.info("Dashboard loading finished", tag: LogTags.lifecycle)
    }

    func handleError(_ error: Error) {
        Log.error("Dashboard error: \(error)", tag: LogTags.general)
    }
}

// ─── 4. Logging from an actor ─────────────────────────────────────────────────

actor DataStore {
    private var cache: [String: Data] = [:]

    func store(_ data: Data, forKey key: String) {
        cache[key] = data
        Log.debug("Cached \(data.count) bytes for key '\(key)'")
    }

    func retrieve(forKey key: String) -> Data? {
        if let data = cache[key] {
            Log.debug("Cache hit for key '\(key)'")
            return data
        }
        Log.warning("Cache miss for key '\(key)'", tag: LogTags.performance)
        return nil
    }
}

// ─── 5. Custom tag ───────────────────────────────────────────────────────────
//
// Extend LogTags with domain-specific tags. These map to os.Logger subsystem
// and category, making them filterable in Console.app and Instruments.

extension LogTags {
    static let payments = LogTag(
        subsystem: "com.example.app.payments",
        prefix: "💳",
        name: "Payments"
    )
}

func paymentFlow(orderId: String, amount: Double) {
    Log.info(
        "Payment initiated — order: \(orderId), amount: \(amount, precision: 2)",
        tag: LogTags.payments
    )
    // … payment logic …
    Log.info("Payment authorised — order: \(orderId)", tag: LogTags.payments)
}

// ─── 6. Message interpolation ─────────────────────────────────────────────────
//
// LogMessage supports rich interpolation helpers for common value types, and
// Beaver evaluates log-message expressions only after level filtering passes.

struct RequestMetrics: Codable {
    let endpoint: String
    let statusCode: Int
    let durationMs: Double
}

func logRequestMetrics(_ metrics: RequestMetrics) {
    // Codable type as pretty-printed JSON
    Log.debug("Request metrics:\n\(json: metrics)", tag: LogTags.api)

    // Double with precision
    Log.info(
        "Request to \(metrics.endpoint) completed in \(metrics.durationMs, precision: 1) ms",
        tag: LogTags.api
    )

    // Array
    let retryAttempts = [1, 2, 3]
    Log.debug("Retry history: \(retryAttempts)", tag: LogTags.network)

    // Optional
    let userId: String? = nil
    Log.debug("Acting user: \(userId)", tag: LogTags.auth)
}

// ─── 7. Custom sink — plain text to stdout ────────────────────────────────────
//
// Implement LogSink to route logs to any destination. The protocol is Sendable,
// so implementations must be safe for concurrent use.

struct PrintSink: LogSink {
    func writeLog(
        logLevel: LogLevel,
        logTag: LogTag,
        message: LogMessage,
        context: LogContext
    ) {
        let file = String(describing: context.file).split(separator: "/").last.map(String.init) ?? "?"
        print("[\(logLevel.name)] [\(logTag.identifier)] \(file):\(context.line) — \(message.value)")
    }
}

func configureWithPrintSink() async {
    await Log.configure(.init(
        minimumLevel: .debug,
        sinks: [OSLogSink(), PrintSink()]
    ))
}

// ─── 8. Async / fire-and-forget sink ──────────────────────────────────────────
//
// If your sink does I/O, dispatch work internally so writeLog returns immediately.

final class RemoteLogSink: LogSink, @unchecked Sendable {
    private let queue = DispatchQueue(label: "com.example.remote-log-sink", qos: .utility)

    func writeLog(
        logLevel: LogLevel,
        logTag: LogTag,
        message: LogMessage,
        context: LogContext
    ) {
        let text = message.value        // capture before async hop
        let level = logLevel.name
        queue.async { self.send(text, level: level) }
    }

    private func send(_ text: String, level: String) {
        // Build and fire an HTTP request to your log aggregation service here.
        _ = (text, level)
    }
}

// ─── 9. Testing — inject an in-memory sink ────────────────────────────────────
//
// During tests, configure the shared logger with an in-memory sink to assert
// on emitted messages without real OSLog output.
//
// See BeaverTests/TestSink.swift for the implementation used in the test suite.
//
//   func testPaymentLogging() async {
//       let sink = TestSink()
//       await Log.configure(.init(minimumLevel: .debug, sinks: [sink]))
//
//       paymentFlow(orderId: "order-1", amount: 99.99)
//
//       XCTAssertTrue(sink.entries.contains { $0.message.contains("order-1") })
//   }
