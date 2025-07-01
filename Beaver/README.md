# Beaver 🦫

A modern, flexible Swift logging framework that seamlessly integrates with Apple's unified logging system.

## Features

- 🚀 **High Performance**: Lazy evaluation with `@autoclosure` parameters
- 🔒 **Thread Safe**: Concurrent logging operations with proper synchronization
- 🎯 **Structured Logging**: Organize logs with tags and categories
- 🍎 **OSLog Integration**: Automatic integration with Apple's unified logging
- 🔧 **Extensible**: Protocol-based architecture for custom output destinations
- 📱 **Cross Platform**: iOS 14+, macOS 11+, tvOS 14+, watchOS 7+

## Installation

### Swift Package Manager

Add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/Dokidocu/Beaver.git", from: "1.0.0")
]
```

Or add via Xcode: File → Add Package Dependencies

## Usage

### Basic Logging

```swift
import Beaver

// Create a logger with default configuration
let logger = BeaverLoggerBuilder().build()

// Log at different levels
logger.debug("Detailed debugging information")
logger.info("General informational messages")
logger.warning("Warning about potential issues")
logger.error("Error events that need attention")
```

### Custom Configuration

```swift
import Beaver

// Configure logger with custom settings
let logger = BeaverLoggerBuilder()
    .setLogLevel(.debug)
    .addLogSink(ConsoleLogSink())
    .addLogSink(FileLogSink(fileURL: logFileURL))
    .build()

logger.info("Application started with custom configuration")
```

### Tagged Logging

Organize your logs with tags for better categorization:

```swift
import Beaver

// Using built-in tags
let networkTag = NetworkTag()
let logger = BeaverLoggerBuilder().build()

logger.info(tag: networkTag, message: "API request initiated")
logger.error(tag: networkTag, message: "Network request failed")

// Custom tags
struct PaymentTag: LogTag {
    let subsystem = Bundle.main.bundleIdentifier ?? "com.yourapp"
    let category = "Payment"
}

let paymentTag = PaymentTag()
logger.info(tag: paymentTag, message: "Payment processed successfully")
```

## Components

### BeaverLogger

The core logging engine that handles message processing and distribution to multiple output destinations.

**Key Features:**
- Thread-safe operations using dispatch queues and locks
- Automatic OSLog integration with proper log type mapping
- Performance optimization with lazy message evaluation
- Support for multiple simultaneous log sinks

### BeaverLoggerBuilder

Builder pattern for configuring logger instances with a fluent API.

```swift
let logger = BeaverLoggerBuilder()
    .setLogLevel(.warning)  // Only log warnings and errors
    .addLogSink(sink1)      // Add custom sink
    .addLogSink(sink2)      // Add another sink
    .build()                // Create configured logger
```

### Log Levels

Four standard logging levels with automatic OSLog mapping:

- **Debug** (`LogLevel.debug`): Detailed information for debugging → `OSLogType.debug`
- **Info** (`LogLevel.info`): General informational messages → `OSLogType.info`
- **Warning** (`LogLevel.warning`): Warning messages → `OSLogType.default`
- **Error** (`LogLevel.error`): Error events → `OSLogType.error`

Messages below the configured level are automatically filtered out for performance.

### Log Tags

Tags provide structured categorization using subsystem and category:

```swift
public protocol LogTag {
    var subsystem: String { get }  // Usually your bundle identifier
    var category: String { get }   // Specific feature or module
}
```

**Built-in Tags:**
- `GeneralTag` - General application logs
- `NetworkTag` - Network operations
- `DatabaseTag` - Database operations  
- `UITag` - User interface events

### Log Sinks

Output destinations that implement the `LogSink` protocol:

```swift
public protocol LogSink {
    func write(_ message: String, level: LogLevel, tag: LogTag?)
}
```

**Built-in Sinks:**
- `ConsoleLogSink` - Standard console output
- `FileLogSink` - File-based logging with proper error handling

## Creating Custom Components

### Custom Log Sinks

Create custom output destinations for logs:

```swift
struct NetworkLogSink: LogSink {
    private let endpoint: URL
    
    func write(_ message: String, level: LogLevel, tag: LogTag?) {
        // Send logs to your analytics service
        let logData = [
            "message": message,
            "level": level.rawValue,
            "subsystem": tag?.subsystem,
            "category": tag?.category,
            "timestamp": ISO8601DateFormatter().string(from: Date())
        ]
        
        sendToServer(logData, to: endpoint)
    }
    
    private func sendToServer(_ data: [String: Any?], to url: URL) {
        // Implementation for network logging
    }
}

// Use in configuration
let logger = BeaverLoggerBuilder()
    .addLogSink(NetworkLogSink(endpoint: URL(string: "https://api.example.com/logs")!))
    .build()
```

### Custom Log Tags

Create domain-specific tags for better log organization:

```swift
struct AuthenticationTag: LogTag {
    let subsystem = Bundle.main.bundleIdentifier ?? "com.yourapp"
    let category = "Authentication"
}

struct DatabaseTag: LogTag {
    let subsystem = Bundle.main.bundleIdentifier ?? "com.yourapp"  
    let category = "Database"
}

// Usage
let authTag = AuthenticationTag()
let dbTag = DatabaseTag()

logger.info(tag: authTag, message: "User login attempt")
logger.error(tag: dbTag, message: "Database connection failed")
```

## OSLog Integration

Beaver automatically integrates with Apple's unified logging system. Your logs will appear in:

- **Xcode Console**: During development and debugging
- **Console.app**: On macOS for system-wide log viewing
- **Instruments**: For performance analysis and debugging

The integration preserves your tag information:
- `LogTag.subsystem` → OSLog subsystem
- `LogTag.category` → OSLog category
- `LogLevel` → Appropriate `OSLogType`

## Performance Considerations

Beaver is designed for high performance in production environments:

### Lazy Evaluation
```swift
// Message is only constructed if debug level is enabled
logger.debug("Expensive operation result: \(performExpensiveCalculation())")
```

### Async Processing
All log operations are performed asynchronously to avoid blocking your main application logic.

### Early Filtering
Messages below the configured log level are filtered out before any processing occurs.

### Thread Safety
All operations are thread-safe and can be called from any queue without additional synchronization.

## Advanced Usage

### Multiple Loggers
Create specialized loggers for different parts of your application:

```swift
// Network logger with file output
let networkLogger = BeaverLoggerBuilder()
    .setLogLevel(.info)
    .addLogSink(FileLogSink(fileURL: networkLogURL))
    .build()

// UI logger with console output  
let uiLogger = BeaverLoggerBuilder()
    .setLogLevel(.debug)
    .addLogSink(ConsoleLogSink())
    .build()

// Use appropriate logger for context
networkLogger.info(tag: NetworkTag(), message: "API call completed")
uiLogger.debug(tag: UITag(), message: "Button tapped")
```

### Conditional Logging
Leverage Swift's lazy evaluation for expensive log messages:

```swift
// Only executes expensive operation if warning level is enabled
logger.warning("Performance metrics: \(generateDetailedMetrics())")
```

## Best Practices

### 1. Use Appropriate Log Levels
- **Debug**: Verbose information useful during development
- **Info**: General application flow and important events
- **Warning**: Potentially harmful situations that don't stop execution
- **Error**: Error events that might affect functionality

### 2. Create Meaningful Tags
Organize logs by feature or subsystem for easier filtering and analysis:

```swift
struct FeatureXTag: LogTag {
    let subsystem = "com.yourapp"
    let category = "FeatureX"
}
```

### 3. Use Lazy Evaluation
Take advantage of `@autoclosure` for expensive log message construction:

```swift
// Good: Only constructs message if needed
logger.debug("User data: \(user.debugDescription)")

// Less efficient: Always constructs message
let message = "User data: \(user.debugDescription)"
logger.debug(message)
```

### 4. Configure Once
Set up your logger configuration early in your application lifecycle:

```swift
// In your App delegate or main app file
let logger = BeaverLoggerBuilder()
    .setLogLevel(.info)
    .addLogSink(ConsoleLogSink())
    .addLogSink(FileLogSink(fileURL: logFileURL))
    .build()
```

## Requirements

- **iOS**: 14.0+
- **macOS**: 11.0+
- **tvOS**: 14.0+
- **watchOS**: 7.0+
- **Xcode**: 12.0+
- **Swift**: 5.5+

## Architecture

Beaver follows a protocol-oriented architecture that emphasizes:

- **Separation of Concerns**: Clear boundaries between logging, formatting, and output
- **Extensibility**: Easy to add new sinks, tags, and behaviors
- **Performance**: Optimized for production use with minimal overhead
- **Apple Integration**: Seamless integration with platform logging systems

## Thread Safety

All Beaver components are designed to be thread-safe:

- **BeaverLogger**: Uses internal synchronization for concurrent access
- **Log Sinks**: Called from background queues to avoid blocking
- **Configuration**: Builder pattern ensures safe setup before use

## Error Handling

Beaver handles errors gracefully:

- **Sink Failures**: Individual sink failures don't affect other sinks
- **Invalid Configuration**: Builder pattern validates configuration at build time
- **Resource Issues**: File sinks handle disk space and permission issues

## Contributing

Beaver welcomes contributions! Areas where you can help:

- Additional built-in log sinks (database, network, etc.)
- Performance improvements
- Documentation enhancements
- Platform-specific optimizations
- Additional built-in tags for common use cases

## License

[Add your license information here]

---

**Beaver** 🦫 - *Building better logs, one message at a time.*
