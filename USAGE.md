# Beaver Usage Guide

Comprehensive examples and best practices for the Beaver logging framework.

## Table of Contents

1. [Quick Start](#quick-start)
2. [Configuration](#configuration)
3. [Logging API](#logging-api)
4. [Log Tags](#log-tags)
5. [Message Interpolation](#message-interpolation)
6. [Custom Sinks](#custom-sinks)
7. [Testing](#testing)
8. [Best Practices](#best-practices)

---

## Quick Start

```swift
import Beaver

// 1. Configure once at startup
await Log.configure(.init(minimumLevel: .info, sinks: [OSLogSink()]))

// 2. Log from anywhere — no await required
Log.info("App launched", tag: LogTags.lifecycle)
Log.error("Request failed: \(error)", tag: LogTags.network)
```

---

## Configuration

Call `Log.configure` once during app startup. All logging after this point uses the new pipeline atomically. The default configuration (before calling `configure`) logs everything at `.debug` to `OSLogSink`.

```swift
// SwiftUI App
@main
struct MyApp: App {
    init() {
        Task {
            await Log.configure(.init(
                minimumLevel: .debug,
                sinks: [OSLogSink()]
            ))
        }
    }

    var body: some Scene {
        WindowGroup { ContentView() }
    }
}
```

```swift
// UIKit AppDelegate
func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
) -> Bool {
    Task {
        await Log.configure(.init(
            minimumLevel: .info,
            sinks: [OSLogSink(), MyRemoteSink()]
        ))
    }
    return true
}
```

### Environment-based configuration

```swift
#if DEBUG
let level: LogLevel = .debug
#else
let level: LogLevel = .warning
#endif

await Log.configure(.init(minimumLevel: level, sinks: [OSLogSink()]))
```

---

## Logging API

### Static convenience (recommended)

```swift
Log.debug("Cache miss for key '\(key)'")
Log.info("User authenticated", tag: LogTags.auth)
Log.warning("Response time exceeded threshold", tag: LogTags.performance)
Log.error("Payment failed: \(error)", tag: LogTags.payments)
```

The `tag` parameter defaults to `LogTags.general` when omitted.

### Explicit level

```swift
Log.shared.log(.info, tag: LogTags.lifecycle, "Scene became active")
```

### From `@MainActor` or any actor

All log methods are `nonisolated` — no `await`, no `Task.detached`:

```swift
@MainActor
final class HomeViewModel: ObservableObject {
    func loadData() async {
        Log.info("Loading started", tag: LogTags.network)
        // …
        Log.info("Loading finished", tag: LogTags.network)
    }
}

actor DataStore {
    func save(_ item: Item) {
        Log.debug("Saving item \(item.id)")
        // …
    }
}
```

---

## Log Tags

Tags categorise log entries and map to `os.Logger` subsystem/category, making logs filterable in Console.app and Instruments.

### Built-in tags

```swift
LogTags.general       // General application logs (default)
LogTags.lifecycle     // App/scene lifecycle events
LogTags.performance   // Timing and metrics
LogTags.network       // Transport-level networking
LogTags.api           // API and backend
LogTags.auth          // Authentication and session
LogTags.oauth         // OAuth token lifecycle
LogTags.ui            // UI flow and navigation
LogTags.accessibility // Accessibility behaviour
```

### Custom tags

Define domain-specific tags as static members of a `LogTags` extension:

```swift
extension LogTags {
    static let payments = LogTag(
        subsystem: "com.example.app.payments",
        prefix: "💳",
        name: "Payments"
    )

    static let sync = LogTag(
        subsystem: "com.example.app.sync",
        prefix: "🔄",
        name: "Sync"
    )
}

Log.info("Payment authorised — order: \(orderId)", tag: LogTags.payments)
```

---

## Message Interpolation

`LogMessage` uses `ExpressibleByStringInterpolation` for lazy, zero-overhead formatting. Messages are constructed only if they pass the minimum level filter.

```swift
// Double with precision
Log.debug("Duration: \(duration, precision: 2) ms")

// Array
let ids = [1, 2, 3]
Log.debug("Processing IDs: \(ids)")          // "Processing IDs: [1, 2, 3]"

// Dictionary
let meta: [String: Any] = ["attempt": 1]
Log.debug("Meta: \(meta)")                   // "Meta: {attempt: 1}"

// Optional
let userId: String? = nil
Log.debug("Acting user: \(userId)")          // "Acting user: nil"

// Codable as pretty-printed JSON
struct Response: Codable { let status: Int; let body: String }
Log.debug("Response:\n\(json: response)")

// [String: Any] as pretty-printed JSON
let payload: [String: Any] = ["key": "value"]
Log.debug("Payload:\n\(json: payload)")
```

---

## Custom Sinks

Implement `LogSink` to route logs to any destination. The protocol is `Sendable`, so implementations must be safe for concurrent use.

### Simple synchronous sink

```swift
struct PrintSink: LogSink {
    func writeLog(
        logLevel: LogLevel,
        logTag: LogTag,
        message: LogMessage,
        context: LogContext
    ) {
        let file = String(describing: context.file).split(separator: "/").last.map(String.init) ?? "?"
        print("[\(logLevel.rawValue.uppercased())] [\(logTag.identifier)] \(file):\(context.line) — \(message.value)")
    }
}
```

### Async fire-and-forget sink

If your sink performs I/O, dispatch internally so `writeLog` returns immediately:

```swift
final class RemoteLogSink: LogSink, @unchecked Sendable {
    private let queue = DispatchQueue(label: "com.example.remote-log", qos: .utility)

    func writeLog(
        logLevel: LogLevel,
        logTag: LogTag,
        message: LogMessage,
        context: LogContext
    ) {
        let text = message.value        // capture before async hop
        let level = logLevel.rawValue
        queue.async { self.send(text, level: level) }
    }

    private func send(_ text: String, level: String) { /* HTTP call */ }
}
```

### Multiple sinks

```swift
await Log.configure(.init(
    minimumLevel: .debug,
    sinks: [OSLogSink(), PrintSink(), RemoteLogSink()]
))
```

---

## Testing

Configure the shared logger with a `TestSink` in your test suite to assert on emitted messages without real OSLog output.

```swift
import XCTest
import Beaver

// In-memory test sink (matches BeaverTests/TestSink.swift)
final class TestSink: LogSink, @unchecked Sendable {
    struct Entry { let level: LogLevel; let tag: LogTag; let message: String }
    private(set) var entries: [Entry] = []
    private let lock = NSLock()

    func writeLog(logLevel: LogLevel, logTag: LogTag, message: LogMessage, context: LogContext) {
        lock.withLock { entries.append(Entry(level: logLevel, tag: logTag, message: message.value)) }
    }
}

final class PaymentTests: XCTestCase {
    func testPaymentLogging() async throws {
        let sink = TestSink()
        await Log.configure(.init(minimumLevel: .debug, sinks: [sink]))

        processPayment(orderId: "order-1", amount: 99.99)

        XCTAssertTrue(sink.entries.contains { $0.message.contains("order-1") })
        XCTAssertEqual(sink.entries.first?.level, .info)
    }
}
```

---

## Best Practices

### 1. Prefer static convenience methods

```swift
// ✅ Preferred
Log.info("User logged in", tag: LogTags.auth)

// Also fine — for explicit level passing
Log.shared.log(.info, tag: LogTags.auth, "User logged in")
```

### 2. Use appropriate levels

| Level | Use for |
|-------|---------|
| `.debug` | Verbose development detail, cache hits/misses |
| `.info` | Application flow milestones, user actions |
| `.warning` | Unexpected but recoverable situations |
| `.error` | Failures that affect functionality |

### 3. Define tags once, reuse everywhere

Tags live in `LogTags.swift` as static members. Avoid ad-hoc `LogTag(...)` literals scattered across the codebase.

### 4. Don't concatenate before logging

```swift
// ✅ Lazy — string built only if level passes filter
Log.debug("User data: \(user)")

// ❌ Eager — always builds the string
let msg = "User data: \(user)"
Log.debug(msg)
```

### 5. Keep sinks fast and non-blocking

Sinks are called synchronously on the caller's thread. Any I/O must be dispatched internally.
