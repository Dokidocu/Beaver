# Beaver 🦫

A lightweight, Swift 6-compatible logging framework that integrates with Apple's unified logging system (OSLog) and supports custom output sinks.

## Features

- **Zero boilerplate** — log from any thread, actor, or `@MainActor` context with no `await`
- **Swift 6 ready** — strict concurrency safe; actor-isolated configuration, `nonisolated` log path
- **OSLog integration** — bridges to `os.Logger` with proper subsystem/category/level mapping
- **Structured tags** — categorise logs by feature area; maps directly to OSLog subsystem and category
- **Rich message interpolation** — format doubles, arrays, dictionaries, Codable types, and JSON inline
- **Extensible** — implement `LogSink` to add any output destination (file, network, analytics, etc.)
- **Cross-platform** — iOS 14+, macOS 11+, tvOS 14+, watchOS 7+

## Installation

### Swift Package Manager

Add Beaver to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/Dokidocu/Beaver.git", from: "1.0.0")
]
```

Or add via Xcode → File → Add Package Dependencies.

## Quick Start

```swift
import Beaver

// 1. Configure once at startup (the only async call)
await Log.configure(.init(minimumLevel: .info, sinks: [OSLogSink()]))

// 2. Log from anywhere — no await, works on any thread
Log.info("App launched", tag: LogTags.lifecycle)
Log.debug("User tapped login", tag: LogTags.ui)
Log.warning("Cache miss for key \(key)", tag: LogTags.performance)
Log.error("Request failed: \(error)", tag: LogTags.network)
```

## Configuration

`Log.Configuration` accepts a minimum log level and a list of sinks. Messages below the minimum level are dropped before reaching any sink.

```swift
// Production: only warnings and above, routed to OSLog
await Log.configure(.init(
    minimumLevel: .warning,
    sinks: [OSLogSink()]
))

// Development: all levels, multiple destinations
await Log.configure(.init(
    minimumLevel: .debug,
    sinks: [OSLogSink(), MyFileSink()]
))
```

The default configuration (before `configure` is called) logs everything at `.debug` level to `OSLogSink`.

## Logging API

### Static convenience (recommended)

```swift
Log.debug("…", tag: LogTags.general)
Log.info("…", tag: LogTags.network)
Log.warning("…", tag: LogTags.performance)
Log.error("…", tag: LogTags.auth)
```

The `tag` parameter defaults to `LogTags.general` when omitted.

### Explicit level

```swift
Log.shared.log(.info, tag: LogTags.lifecycle, "Scene became active")
```

### From inside an actor or `@MainActor` type

No special handling is required. All log methods are `nonisolated` and synchronous:

```swift
@MainActor
final class HomeViewModel: ObservableObject {
    func loadData() {
        Log.info("Loading data…", tag: LogTags.network)
        // …
    }
}
```

## Log Levels

| Level | OSLog type | Typical use |
|-------|-----------|-------------|
| `.debug` | `debug` | Verbose development detail |
| `.info` | `info` | General application flow |
| `.warning` | `fault` | Unexpected but recoverable situations |
| `.error` | `error` | Failures that affect functionality |

## Log Tags

Tags identify the feature area that emitted a log. They map to the `subsystem` and `category` fields of `os.Logger`, making logs easily filterable in Console.app and Instruments.

### Built-in tags

```swift
LogTags.general       // General application logs
LogTags.lifecycle     // OS-driven app/scene lifecycle
LogTags.performance   // Timing and performance metrics
LogTags.network       // Transport-level networking
LogTags.api           // API and backend contract
LogTags.auth          // Authentication and session state
LogTags.oauth         // OAuth token lifecycle
LogTags.ui            // UI flow and navigation
LogTags.accessibility // Accessibility behaviour
```

### Custom tags

```swift
extension LogTags {
    static let payments = LogTag(
        subsystem: "com.example.app.payments",
        prefix: "💳",
        name: "Payments"
    )
}

Log.info("Payment authorised", tag: LogTags.payments)
```

## Message Interpolation

`LogMessage` uses `ExpressibleByStringInterpolation` so messages are constructed lazily — if the log level is filtered out, the string is never built.

```swift
let value = 3.14159
Log.debug("Pi ≈ \(value, precision: 2)")           // "Pi ≈ 3.14"
Log.debug("Pi ≈ \(value, precision: 4)")           // "Pi ≈ 3.1416"

let ids = [1, 2, 3]
Log.debug("IDs: \(ids)")                           // "IDs: [1, 2, 3]"

let meta: [String: Any] = ["attempt": 1, "timeout": 30]
Log.debug("Meta: \(meta)")                         // "Meta: {attempt: 1, timeout: 30}"

struct Response: Codable { let status: Int; let body: String }
let response = Response(status: 200, body: "OK")
Log.debug("Response:\n\(json: response)")          // pretty-printed JSON
```

## Custom Sinks

Implement `LogSink` to route logs to any destination:

```swift
import Beaver
import Foundation

struct PrintSink: LogSink {
    func writeLog(
        logLevel: LogLevel,
        logTag: LogTag,
        message: LogMessage,
        context: LogContext
    ) {
        let file = String(describing: context.file).split(separator: "/").last ?? "?"
        print("[\(logLevel)] [\(logTag.identifier)] \(file):\(context.line) — \(message.value)")
    }
}
```

Use it alongside the default OSLog sink:

```swift
await Log.configure(.init(
    minimumLevel: .debug,
    sinks: [OSLogSink(), PrintSink()]
))
```

### Async sinks (fire-and-forget)

If your sink performs I/O, dispatch work internally so `writeLog` returns immediately:

```swift
final class RemoteLogSink: LogSink, @unchecked Sendable {
    private let queue = DispatchQueue(label: "remote-log-sink", qos: .utility)

    func writeLog(
        logLevel: LogLevel,
        logTag: LogTag,
        message: LogMessage,
        context: LogContext
    ) {
        let payload = message.value   // capture value before async hop
        queue.async { self.send(payload) }
    }

    private func send(_ payload: String) { /* network call */ }
}
```

## Design

```
Log (actor)
    └── LoggerState (NSLock-protected)
            └── LoggerFacade (level filter)
                    └── LogSinks (multiplexer)
                            ├── OSLogSink
                            └── … custom sinks
```

- **`Log`** — actor; holds `LoggerState` as a `nonisolated let`; all log methods are `nonisolated` so they never suspend.
- **`LoggerState`** — `@unchecked Sendable` class; guards the active `LoggerFacade` with an `NSLock`; enables lock-free reads after a single load.
- **`LoggerFacade`** — immutable filter; drops messages below the configured minimum level.
- **`LogSinks`** — fans a message out to all configured sinks.
- **`OSLogSink`** — bridges to `os.Logger`; caches `Logger` instances per subsystem/category.

## Requirements

| Platform | Minimum |
|----------|---------|
| iOS | 14.0 |
| macOS | 11.0 |
| tvOS | 14.0 |
| watchOS | 7.0 |
| Swift | 5.9 |
| Xcode | 15.0 |

## License

See [LICENSE](LICENSE).

---

**Beaver** 🦫 — *Building better logs, one message at a time.*
