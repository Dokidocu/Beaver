# ``Beaver``

A flexible Swift logging framework with support for multiple log sinks and Apple's OSLog integration.

## Overview

Beaver provides structured logging with customizable log levels, tags, and output destinations. It integrates seamlessly with Apple's unified logging system while allowing custom log processing through the LogSink protocol.

## Features

- **Log Level Filtering**: Only logs messages at or above the configured level
- **Custom Log Sinks**: Implement your own log destinations (console, file, network, etc.)
- **OSLog Integration**: Automatic integration with Apple's unified logging system
- **Structured Logging**: Use tags to categorize and organize logs by subsystem
- **Thread Safe**: Safe to use from multiple threads with internal queuing
- **Performance Optimized**: Uses `@autoclosure` to defer expensive string operations
- **Builder Pattern**: Fluent API for easy configuration

## Basic Usage

```swift
import Beaver

// Simple logging with default configuration
Beaver.info("Application started")
Beaver.error("Something went wrong")

// Logging with custom tags
let networkTag = NetworkTag()
Beaver.info(tag: networkTag, message: "API request started")
Beaver.error(tag: networkTag, message: "Request failed with error")
```

## Advanced Configuration

```swift
// Configure Beaver with custom settings
let fileURL = URL(fileURLWithPath: "/tmp/app.log")
let fileSink = FileLogSink(fileURL: fileURL)

Beaver.configure(with: BeaverBuilder()
    .setLogLevel(.warning)  // Only log warnings and errors
    .addLogSink(ConsoleLogSink())  // Log to console
    .addLogSink(fileSink)  // Also log to file
    .setSubsystem("com.myapp.logging")
    .setCategory("Main")
)

// Now all logging will use the configured settings
Beaver.warning("This will be logged")
Beaver.debug("This will be filtered out")
```

## Custom Log Tags

```swift
struct AuthTag: LogTag {
    var subsystem = "com.myapp.auth"
    var prefix = "[AUTH] "
    var name = "Authentication"
}

let authTag = AuthTag()
Beaver.info(tag: authTag, message: "User logged in")
```

## Custom Log Sinks

```swift
struct NetworkLogSink: LogSink {
    func writeLog(logLevel: LogLevel, logTag: any LogTag, message: String, file: String, line: Int) {
        // Send logs to your analytics service
        Analytics.track(event: "log", properties: [
            "level": logLevel.name,
            "tag": logTag.name,
            "message": message
        ])
    }
}
```

## Topics

### Core Components

- ``BeaverLogger``
- ``BeaverBuilder``
- ``Beaver``

### Configuration

- ``LogLevel``
- ``LogTag``
- ``LogSink``

### Built-in Tags

- ``GeneralTag``
- ``NetworkTag``
- ``DatabaseTag``
- ``UITag``

### Built-in Sinks

- ``ConsoleLogSink``
- ``FileLogSink``
