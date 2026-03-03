# Beaver 🦫

A modern, flexible Swift logging framework that seamlessly integrates with Apple's unified logging system.

## Overview

Beaver provides a clean, performant, and extensible logging solution for Swift applications across all Apple platforms. Built with modern Swift features and designed for production use, Beaver offers both simplicity for basic use cases and flexibility for advanced logging requirements.

## Architecture

### Core Components

- **BeaverLogger**: The main logging engine that handles message processing, filtering, and distribution
- **BeaverLoggerBuilder**: Configuration builder using the builder pattern for clean setup
- **LogLevel**: Enumeration defining four logging levels with automatic OSLog type mapping
- **LogSink**: Protocol for implementing custom output destinations
- **LogTag**: Protocol for structured log categorization by subsystem and category

### Design Principles

1. **Protocol-Oriented Design**: Extensible architecture using Swift protocols
2. **Thread Safety**: All operations are thread-safe and non-blocking
3. **Performance First**: Lazy evaluation and async processing minimize overhead
4. **Apple Integration**: Seamless OSLog integration preserves platform benefits
5. **Structured Logging**: Tag-based organization for better log management

## Key Features

### High Performance Logging

Beaver uses `@autoclosure` parameters to defer expensive string operations until they're actually needed:

```swift
// Message construction is deferred until log level check passes
logger.debug("Complex calculation: \(performExpensiveOperation())")
```

### Thread-Safe Operations

All logging operations use proper synchronization:
- Internal `NSLock` for logger cache management
- `DispatchQueue` for async log processing
- `@unchecked Sendable` conformance with proper synchronization

### Automatic OSLog Integration

Every log message automatically flows through Apple's unified logging system:
- Preserves subsystem and category information
- Maps log levels to appropriate OSLog types
- Appears in Xcode Console, Console.app, and Instruments

### Flexible Output Destinations

Implement the `LogSink` protocol to create custom output destinations:
- Console output for development
- File logging for persistence
- Network logging for analytics
- Database storage for analysis

## Usage Patterns

### Basic Logger Setup

```swift
import Beaver

// Create logger with default configuration
let logger = BeaverLoggerBuilder().build()

// Log at different levels
logger.debug("Detailed debugging information")
logger.info("Application flow information")
logger.warning("Potential issues")
logger.error("Error conditions")
```

### Advanced Configuration

```swift
// Configure logger with multiple sinks
let logger = BeaverLoggerBuilder()
    .setLogLevel(.info)                    // Filter out debug messages
    .addLogSink(ConsoleLogSink())          // Console output
    .addLogSink(FileLogSink(fileURL: url)) // File output
    .build()
```

### Structured Logging with Tags

```swift
// Use built-in tags
let networkTag = NetworkTag()
logger.error(tag: networkTag, message: "Network request failed")

// Create custom tags
struct PaymentTag: LogTag {
    let subsystem = Bundle.main.bundleIdentifier ?? "com.yourapp"
    let category = "Payment"
}

let paymentTag = PaymentTag()
logger.info(tag: paymentTag, message: "Payment processed")
```

## Implementation Details

### Logger Lifecycle

1. **Configuration**: Use `BeaverLoggerBuilder` to set up logger properties
2. **Creation**: Call `build()` to create configured logger instance
3. **Caching**: Loggers are cached by tag for efficient reuse
4. **Logging**: Messages flow through level filtering, sink processing, and OSLog integration

### Message Processing Flow

1. **Level Check**: Early filtering based on configured log level
2. **Async Processing**: Message handling on background queue
3. **Sink Distribution**: Message sent to all configured sinks
4. **OSLog Integration**: Automatic forwarding to Apple's logging system

### Memory and Performance

- **Lazy Evaluation**: Log messages only constructed when needed
- **Async Operations**: Non-blocking log processing
- **Efficient Caching**: Logger instances cached and reused
- **Early Filtering**: Messages filtered before expensive operations

## Extension Points

### Custom Log Sinks

Implement `LogSink` for custom output destinations:

```swift
public protocol LogSink {
    func write(_ message: String, level: LogLevel, tag: LogTag?)
}
```

Example implementations:
- **FileLogSink**: Persistent file logging with rotation
- **ConsoleLogSink**: Development console output
- **NetworkLogSink**: Remote logging service integration
- **DatabaseLogSink**: Structured storage for analysis

### Custom Log Tags

Implement `LogTag` for domain-specific categorization:

```swift
public protocol LogTag {
    var subsystem: String { get }
    var category: String { get }
}
```

Built-in tag categories:
- **GeneralTag**: General application logging
- **NetworkTag**: Network operations and API calls
- **DatabaseTag**: Data persistence operations
- **UITag**: User interface events and interactions

## Platform Integration

### OSLog Mapping

Beaver automatically maps to OSLog types:
- `LogLevel.debug` → `OSLogType.debug`
- `LogLevel.info` → `OSLogType.info`
- `LogLevel.warning` → `OSLogType.default`
- `LogLevel.error` → `OSLogType.error`

### Platform Availability

- **iOS**: 14.0+ (supports all modern iOS devices)
- **macOS**: 11.0+ (Big Sur and later)
- **tvOS**: 14.0+ (Apple TV 4K and later)
- **watchOS**: 7.0+ (Apple Watch Series 3 and later)

## Development Guidelines

### Recommended Practices

1. **Early Configuration**: Set up logging early in application lifecycle
2. **Appropriate Levels**: Use debug for development, info/warning/error for production
3. **Meaningful Tags**: Create specific tags for different application areas
4. **Lazy Messages**: Take advantage of `@autoclosure` for expensive log construction
5. **Multiple Sinks**: Use different sinks for different environments (development vs. production)

### Performance Considerations

- Configure appropriate log levels for production (typically `.info` or higher)
- Use lazy evaluation for expensive message construction
- Consider file sink rotation for long-running applications
- Monitor log volume in production environments

## Technical Specifications

### Concurrency Model

- **Thread Safety**: All public APIs are thread-safe
- **Async Processing**: Log operations don't block calling thread
- **Queue Management**: Internal dispatch queues handle message processing
- **Lock Usage**: Minimal locking with `NSLock` for cache management

### Memory Management

- **Logger Caching**: Efficient reuse of logger instances
- **Weak References**: Appropriate memory management for long-lived objects
- **Resource Cleanup**: Proper cleanup of file handles and network connections

### Error Handling

- **Graceful Degradation**: Individual sink failures don't affect other sinks
- **Resource Management**: Proper handling of file system and network errors
- **Validation**: Configuration validation during logger creation

---

This documentation covers the complete Beaver logging framework architecture, implementation, and usage patterns without modifying any existing code.
