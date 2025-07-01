# ``Beaver``

A modern, flexible Swift logging framework that seamlessly integrates with Apple's unified logging system.

## Overview

Beaver provides a clean, performant, and extensible logging solution for Swift applications across all Apple platforms. Built with modern Swift features and designed for production use, Beaver offers both simplicity for basic use cases and flexibility for advanced logging requirements.

### Key Features

- **High Performance**: Lazy evaluation with `@autoclosure` parameters minimizes overhead
- **Thread Safety**: All operations are thread-safe with proper synchronization
- **Structured Logging**: Organize logs with tags and categories for better management
- **OSLog Integration**: Automatic integration with Apple's unified logging system
- **Extensible Architecture**: Protocol-based design for custom output destinations
- **Cross Platform**: Support for iOS 14+, macOS 11+, tvOS 14+, watchOS 7+

## Topics

### Essential Components

- ``BeaverLogger``
- ``BeaverLoggerBuilder``
- ``LogLevel``
- ``LogSink``
- ``LogTag``

### Core Protocols

- ``LogSink``
- ``LogTag``

### Getting Started

Create a basic logger and start logging:

```swift
import Beaver

// Basic logger setup
let logger = BeaverLoggerBuilder().build()

// Log at different levels
logger.debug("Detailed debugging information")
logger.info("General application flow")
logger.warning("Potential issues detected")
logger.error("Error conditions occurred")
```

### Advanced Configuration

Configure logger with multiple output destinations:

```swift
// Advanced logger configuration
let logger = BeaverLoggerBuilder()
    .setLogLevel(.info)                    // Filter debug messages
    .addLogSink(ConsoleLogSink())          // Console output
    .addLogSink(FileLogSink(fileURL: url)) // File output
    .build()
```

### Structured Logging

Use tags to categorize and organize log messages:

```swift
// Use built-in tags
let networkTag = NetworkTag()
logger.error(tag: networkTag, message: "API request failed")

// Create custom tags
struct PaymentTag: LogTag {
    let subsystem = Bundle.main.bundleIdentifier ?? "com.yourapp"
    let category = "Payment"
}

let paymentTag = PaymentTag()
logger.info(tag: paymentTag, message: "Payment processed successfully")
```

## Architecture Overview

Beaver follows a protocol-oriented architecture with these design principles:

1. **Performance First**: Lazy evaluation and async processing minimize performance impact
2. **Thread Safety**: All operations are thread-safe and non-blocking
3. **Extensibility**: Protocol-based design allows easy customization
4. **Apple Integration**: Seamless OSLog integration preserves platform benefits
5. **Structured Organization**: Tag-based categorization for better log management

### Message Processing Flow

1. **Level Filtering**: Early filtering based on configured log level
2. **Async Processing**: Message handling on background queue for non-blocking operation
3. **Sink Distribution**: Messages distributed to all configured output destinations
4. **OSLog Integration**: Automatic forwarding to Apple's unified logging system

### Thread Safety Model

- **Logger Cache**: Protected by `NSLock` for thread-safe access
- **Message Processing**: Uses dedicated `DispatchQueue` for async operations
- **Sink Operations**: All sink writes performed on background queues
- **Configuration**: Builder pattern ensures safe setup before concurrent use

## Best Practices

### Choosing Log Levels

- **Debug**: Verbose information useful during development and debugging
- **Info**: General application flow and important business events
- **Warning**: Potentially harmful situations that don't stop execution
- **Error**: Error events that might affect application functionality

### Performance Optimization

Take advantage of lazy evaluation for expensive log message construction:

```swift
// Efficient: Only constructs message if debug level is enabled
logger.debug("Complex calculation result: \(performExpensiveOperation())")

// Less efficient: Always constructs message regardless of level
let result = performExpensiveOperation()
logger.debug("Complex calculation result: \(result)")
```

### Tag Organization

Create meaningful tags for different application areas:

```swift
// Domain-specific tags for better organization
struct AuthenticationTag: LogTag {
    let subsystem = Bundle.main.bundleIdentifier ?? "com.yourapp"
    let category = "Authentication"
}

struct DatabaseTag: LogTag {
    let subsystem = Bundle.main.bundleIdentifier ?? "com.yourapp"
    let category = "Database"
}
```

### Logger Configuration

Set up logger configuration early in application lifecycle:

```swift
// Configure once during app startup
class AppDelegate: UIApplicationDelegate {
    let logger = BeaverLoggerBuilder()
        .setLogLevel(.info)
        .addLogSink(ConsoleLogSink())
        .addLogSink(FileLogSink(fileURL: logFileURL))
        .build()
}
```

## Integration with Apple Platforms

### OSLog Mapping

Beaver automatically maps log levels to appropriate OSLog types:

- `LogLevel.debug` → `OSLogType.debug`
- `LogLevel.info` → `OSLogType.info`
- `LogLevel.warning` → `OSLogType.default`
- `LogLevel.error` → `OSLogType.error`

### Platform Availability

Your logs will appear in all standard Apple debugging tools:

- **Xcode Console**: During development and debugging sessions
- **Console.app**: System-wide log viewing on macOS
- **Instruments**: Performance analysis and debugging workflows

### Subsystem and Category Preservation

Tag information is preserved in OSLog integration:
- `LogTag.subsystem` maps to OSLog subsystem
- `LogTag.category` maps to OSLog category

This allows for effective filtering and analysis in Apple's logging tools.

## Extending Beaver

### Custom Log Sinks

Implement the `LogSink` protocol to create custom output destinations:

```swift
struct NetworkLogSink: LogSink {
    private let endpoint: URL
    
    func write(_ message: String, level: LogLevel, tag: LogTag?) {
        // Send logs to remote analytics service
        let logEntry = createLogEntry(message: message, level: level, tag: tag)
        sendToEndpoint(logEntry)
    }
}
```

### Custom Log Tags

Create domain-specific tags for better log categorization:

```swift
struct FeatureXTag: LogTag {
    let subsystem = "com.yourapp"
    let category = "FeatureX"
}

struct PaymentProcessingTag: LogTag {
    let subsystem = "com.yourapp.payments"
    let category = "Processing"
}
```

## Error Handling

Beaver handles errors gracefully throughout the system:

### Sink Error Isolation

Individual sink failures don't affect other sinks or the logging system:

```swift
// If FileLogSink fails, ConsoleLogSink continues working
let logger = BeaverLoggerBuilder()
    .addLogSink(FileLogSink(fileURL: url))  // May fail due to permissions
    .addLogSink(ConsoleLogSink())           // Continues working
    .build()
```

### Resource Management

Proper handling of system resources:

- File handles are managed appropriately in `FileLogSink`
- Network connections are handled gracefully in custom network sinks
- Memory usage is optimized through efficient caching and cleanup

### Validation

Configuration validation occurs during logger creation to catch issues early:

```swift
// Builder pattern validates configuration before creating logger
let logger = BeaverLoggerBuilder()
    .setLogLevel(.info)     // Validates log level
    .addLogSink(validSink)  // Validates sink implementation
    .build()                // Creates validated logger instance
```

## Performance Characteristics

### Memory Usage

- **Logger Caching**: Efficient reuse of logger instances reduces memory overhead
- **Lazy Evaluation**: Messages only constructed when needed
- **Weak References**: Proper memory management prevents retain cycles

### CPU Performance

- **Early Filtering**: Messages filtered at log level before expensive operations
- **Async Processing**: Non-blocking operations don't impact main thread performance
- **Optimized Paths**: Fast paths for common operations

### I/O Operations

- **Background Queues**: File and network operations performed asynchronously
- **Batching**: Efficient handling of multiple log messages
- **Resource Pooling**: Reuse of expensive resources like file handles

---

This documentation provides comprehensive coverage of the Beaver logging framework based on the current implementation, without modifying any existing code.

