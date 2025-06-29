# 🦫 Beaver

A flexible Swift logging framework with support for multiple log sinks and Apple's OSLog integration.

## Features

- 🎯 **Log Level Filtering**: Only logs messages at or above the configured level
- 🔌 **Custom Log Sinks**: Implement your own log destinations (console, file, network, etc.)
- 🍎 **OSLog Integration**: Automatic integration with Apple's unified logging system
- 🏷️ **Structured Logging**: Use tags to categorize and organize logs by subsystem
- 🧵 **Thread Safe**: Safe to use from multiple threads with internal queuing
- ⚡ **Performance Optimized**: Uses `@autoclosure` to defer expensive string operations
- 🔧 **Builder Pattern**: Fluent API for easy configuration

## Installation

### Swift Package Manager

Add Beaver to your project using Xcode or by adding it to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/yourusername/Beaver.git", from: "1.0.0")
]
```

## Quick Start

```swift
import Beaver

// Simple logging with default configuration
Beaver.info("Application started")
Beaver.error("Something went wrong")

// Logging with custom tags
let networkTag = NetworkTag()
Beaver.info(tag: networkTag, message: "API request started")
Beaver.error(tag: networkTag, message: "Request failed")
```

## Configuration

Configure Beaver with custom settings:

```swift
let fileSink = FileLogSink(fileURL: URL(fileURLWithPath: "/tmp/app.log"))

Beaver.configure(with: BeaverBuilder()
    .setLogLevel(.warning)  // Only log warnings and errors
    .addLogSink(ConsoleLogSink())  // Log to console
    .addLogSink(fileSink)  // Also log to file
    .setSubsystem("com.myapp.logging")
)
```

## Log Levels

Beaver supports four log levels with automatic filtering:

- **Debug**: Detailed information for debugging
- **Info**: General information about app execution
- **Warning**: Something unexpected happened, but the app can continue
- **Error**: A serious problem occurred

```swift
// Configure to only show warnings and errors
Beaver.configure(with: BeaverBuilder().setLogLevel(.warning))

Beaver.debug("This won't be shown")     // Filtered out
Beaver.info("This won't be shown")      // Filtered out  
Beaver.warning("This will be shown")    // ✅ Logged
Beaver.error("This will be shown")      // ✅ Logged
```

## Log Tags

Use tags to categorize your logs by subsystem or feature:

```swift
// Built-in tags
let networkTag = NetworkTag()
let dbTag = DatabaseTag()
let uiTag = UITag()

Beaver.info(tag: networkTag, message: "API request completed")
Beaver.error(tag: dbTag, message: "Database connection failed")
Beaver.warning(tag: uiTag, message: "View update took longer than expected")

// Custom tags
struct AuthTag: LogTag {
    var subsystem = "com.myapp.auth"
    var prefix = "[🔐 AUTH] "
    var name = "Authentication"
}

let authTag = AuthTag()
Beaver.info(tag: authTag, message: "User logged in successfully")
```

## Custom Log Sinks

Implement your own log destinations:

```swift
struct AnalyticsLogSink: LogSink {
    func writeLog(logLevel: LogLevel, logTag: any LogTag, message: String, file: String, line: Int) {
        // Send logs to your analytics service
        Analytics.track(event: "app_log", properties: [
            "level": logLevel.name,
            "subsystem": logTag.subsystem,
            "message": message
        ])
    }
}

// Add to your configuration
Beaver.configure(with: BeaverBuilder()
    .addLogSink(AnalyticsLogSink())
    .addLogSink(ConsoleLogSink())
)
```

## Built-in Log Sinks

### Console Log Sink
Prints formatted logs to the console:

```swift
let consoleSink = ConsoleLogSink()
```

### File Log Sink
Writes logs to a file with automatic file creation:

```swift
let fileURL = URL(fileURLWithPath: "/path/to/logfile.log")
let fileSink = FileLogSink(fileURL: fileURL)
```

## Performance

Beaver uses `@autoclosure` to defer expensive string operations until they're actually needed:

```swift
func expensiveOperation() -> String {
    // This only runs if the log level allows it
    return heavyStringProcessing()
}

// If debug logging is disabled, expensiveOperation() never runs
Beaver.debug("Result: \(expensiveOperation())")
```

## Thread Safety

Beaver is thread-safe and uses internal queuing to handle concurrent logging from multiple threads without blocking your app.

## Integration with Apple's OSLog

Beaver automatically integrates with Apple's unified logging system, so your logs appear in:
- Xcode console
- Console.app
- Instruments
- `log` command line tool

## Documentation

Full documentation is available in the DocC documentation. Build it in Xcode with Product → Build Documentation.

## Requirements

- iOS 14.0+ / macOS 11.0+ / tvOS 14.0+ / watchOS 7.0+
- Swift 5.9+
- Xcode 15.0+

## License

MIT License - see LICENSE file for details.

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request
