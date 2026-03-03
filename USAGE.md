# Beaver Framework Usage Guide

This guide provides comprehensive examples and best practices for using the Beaver logging framework.

## Table of Contents

1. [Basic Usage](#basic-usage)
2. [Configuration](#configuration)
3. [Tagged Logging](#tagged-logging)
4. [Custom Components](#custom-components)
5. [Real-World Examples](#real-world-examples)
6. [Best Practices](#best-practices)
7. [Testing](#testing)

## Basic Usage

### Simple Logging

```swift
import Beaver

// Create a basic logger
let logger = BeaverLoggerBuilder().build()

// Log at different levels
logger.debug("Application started in debug mode")
logger.info("User authentication successful")
logger.warning("API response time exceeded threshold")
logger.error("Failed to save user data")
```

### Logger with Custom Configuration

```swift
import Beaver

// Configure logger with specific settings
let logger = BeaverLoggerBuilder()
    .setLogLevel(.info)  // Only log info, warning, and error
    .addLogSink(ConsoleLogSink())
    .build()

logger.debug("This won't be logged due to level filtering")
logger.info("This will be logged")
logger.error("Critical error occurred")
```

## Configuration

### Multiple Sinks Configuration

```swift
import Beaver

let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
let logFileURL = documentsURL.appendingPathComponent("app.log")

let logger = BeaverLoggerBuilder()
    .setLogLevel(.debug)
    .addLogSink(ConsoleLogSink())        // Console output
    .addLogSink(FileLogSink(fileURL: logFileURL))  // File output
    .build()

logger.info("Application configured with multiple sinks")
```

## Tagged Logging

### Using Built-in Tags

```swift
import Beaver

let logger = BeaverLoggerBuilder().build()

// Network operations
let networkTag = NetworkTag()
logger.info(tag: networkTag, message: "Starting API request to /users")
logger.warning(tag: networkTag, message: "Request timeout, retrying...")
logger.error(tag: networkTag, message: "Network request failed after 3 retries")

// Database operations  
let dbTag = DatabaseTag()
logger.info(tag: dbTag, message: "Database connection established")
logger.error(tag: dbTag, message: "Query execution failed")

// UI events
let uiTag = UITag()
logger.debug(tag: uiTag, message: "User tapped login button")
logger.info(tag: uiTag, message: "Navigation to dashboard completed")
```

### Custom Tag Implementation

```swift
import Beaver

// Authentication-specific logging
struct AuthTag: LogTag {
    let subsystem = Bundle.main.bundleIdentifier ?? "com.example.app"
    let category = "Authentication"
}

// Payment processing logging
struct PaymentTag: LogTag {
    let subsystem = Bundle.main.bundleIdentifier ?? "com.example.app"
    let category = "Payment"
}

// Usage
let logger = BeaverLoggerBuilder().build()
let authTag = AuthTag()
let paymentTag = PaymentTag()

logger.info(tag: authTag, message: "User login attempt")
logger.info(tag: paymentTag, message: "Processing credit card payment")
```

## Custom Components

### Custom Log Sink - Rotating File Logger

```swift
import Beaver
import Foundation

class RotatingFileLogSink: LogSink {
    private let baseURL: URL
    private let maxFileSize: Int
    private let maxFiles: Int
    
    init(baseURL: URL, maxFileSize: Int = 10_000_000, maxFiles: Int = 5) {
        self.baseURL = baseURL
        self.maxFileSize = maxFileSize
        self.maxFiles = maxFiles
    }
    
    func write(_ message: String, level: LogLevel, tag: LogTag?) {
        let timestamp = ISO8601DateFormatter().string(from: Date())
        let subsystem = tag?.subsystem ?? "Unknown"
        let category = tag?.category ?? "General"
        
        let logEntry = "[\(timestamp)] [\(level.rawValue.uppercased())] [\(subsystem):\(category)] \(message)\n"
        
        let currentLogFile = baseURL.appendingPathComponent("app.log")
        
        // Check file size and rotate if needed
        if shouldRotateLog(at: currentLogFile) {
            rotateLogFiles()
        }
        
        // Append to current log file
        if let data = logEntry.data(using: .utf8) {
            if FileManager.default.fileExists(atPath: currentLogFile.path) {
                if let fileHandle = try? FileHandle(forWritingTo: currentLogFile) {
                    defer { fileHandle.closeFile() }
                    fileHandle.seekToEndOfFile()
                    fileHandle.write(data)
                }
            } else {
                try? data.write(to: currentLogFile)
            }
        }
    }
    
    private func shouldRotateLog(at url: URL) -> Bool {
        guard let attributes = try? FileManager.default.attributesOfItem(atPath: url.path),
              let fileSize = attributes[.size] as? Int else {
            return false
        }
        return fileSize > maxFileSize
    }
    
    private func rotateLogFiles() {
        let fileManager = FileManager.default
        
        // Remove oldest log file
        let oldestLog = baseURL.appendingPathComponent("app.\(maxFiles - 1).log")
        try? fileManager.removeItem(at: oldestLog)
        
        // Rotate existing files
        for i in (1..<maxFiles).reversed() {
            let current = baseURL.appendingPathComponent("app.\(i).log")
            let next = baseURL.appendingPathComponent("app.\(i + 1).log")
            try? fileManager.moveItem(at: current, to: next)
        }
        
        // Move current log to .1
        let currentLog = baseURL.appendingPathComponent("app.log")
        let firstRotated = baseURL.appendingPathComponent("app.1.log")
        try? fileManager.moveItem(at: currentLog, to: firstRotated)
    }
}

// Usage
let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
let logDirURL = documentsURL.appendingPathComponent("Logs")
try? FileManager.default.createDirectory(at: logDirURL, withIntermediateDirectories: true)

let logger = BeaverLoggerBuilder()
    .setLogLevel(.debug)
    .addLogSink(RotatingFileLogSink(baseURL: logDirURL))
    .build()
```

### Custom Log Sink - Network Logger

```swift
import Beaver
import Foundation

class NetworkLogSink: LogSink {
    private let endpoint: URL
    private let session: URLSession
    private let queue = DispatchQueue(label: "network-log-sink", qos: .utility)
    
    init(endpoint: URL, session: URLSession = .shared) {
        self.endpoint = endpoint
        self.session = session
    }
    
    func write(_ message: String, level: LogLevel, tag: LogTag?) {
        queue.async { [weak self] in
            self?.sendLogToServer(message: message, level: level, tag: tag)
        }
    }
    
    private func sendLogToServer(message: String, level: LogLevel, tag: LogTag?) {
        let logData: [String: Any] = [
            "timestamp": ISO8601DateFormatter().string(from: Date()),
            "level": level.rawValue,
            "message": message,
            "subsystem": tag?.subsystem ?? "unknown",
            "category": tag?.category ?? "general",
            "platform": "iOS",
            "version": Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") ?? "unknown"
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: logData) else {
            return
        }
        
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        session.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Failed to send log to server: \(error)")
            }
        }.resume()
    }
}

// Usage
let networkSink = NetworkLogSink(
    endpoint: URL(string: "https://api.example.com/logs")!
)

let logger = BeaverLoggerBuilder()
    .setLogLevel(.warning)  // Only send warnings and errors to server
    .addLogSink(ConsoleLogSink())  // Local console output
    .addLogSink(networkSink)       // Remote server logging
    .build()
```

## Real-World Examples

### E-commerce Application Logging

```swift
import Beaver

class ECommerceLogger {
    static let shared = ECommerceLogger()
    
    private let logger: BeaverLogger
    
    // Custom tags for different app areas
    private let userTag = UserTag()
    private let cartTag = CartTag()
    private let orderTag = OrderTag()
    private let paymentTag = PaymentTag()
    private let inventoryTag = InventoryTag()
    
    private init() {
        let logDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            .first!.appendingPathComponent("Logs")
        
        try? FileManager.default.createDirectory(at: logDirectory, 
                                               withIntermediateDirectories: true)
        
        self.logger = BeaverLoggerBuilder()
            .setLogLevel(.info)
            .addLogSink(ConsoleLogSink())
            .addLogSink(FileLogSink(fileURL: logDirectory.appendingPathComponent("app.log")))
            .build()
    }
    
    // User actions
    func userLoggedIn(userId: String) {
        logger.info(tag: userTag, message: "User logged in: \(userId)")
    }
    
    func userLoggedOut(userId: String) {
        logger.info(tag: userTag, message: "User logged out: \(userId)")
    }
    
    // Shopping cart
    func itemAddedToCart(productId: String, userId: String) {
        logger.info(tag: cartTag, message: "Item \(productId) added to cart for user \(userId)")
    }
    
    func cartCheckout(userId: String, itemCount: Int, total: Decimal) {
        logger.info(tag: cartTag, message: "Cart checkout initiated - User: \(userId), Items: \(itemCount), Total: $\(total)")
    }
    
    // Orders
    func orderCreated(orderId: String, userId: String) {
        logger.info(tag: orderTag, message: "Order created: \(orderId) for user \(userId)")
    }
    
    func orderFulfilled(orderId: String) {
        logger.info(tag: orderTag, message: "Order fulfilled: \(orderId)")
    }
    
    func orderCancelled(orderId: String, reason: String) {
        logger.warning(tag: orderTag, message: "Order cancelled: \(orderId), Reason: \(reason)")
    }
    
    // Payments
    func paymentProcessed(orderId: String, amount: Decimal, method: String) {
        logger.info(tag: paymentTag, message: "Payment processed - Order: \(orderId), Amount: $\(amount), Method: \(method)")
    }
    
    func paymentFailed(orderId: String, error: String) {
        logger.error(tag: paymentTag, message: "Payment failed - Order: \(orderId), Error: \(error)")
    }
    
    // Inventory
    func inventoryUpdated(productId: String, newQuantity: Int) {
        logger.debug(tag: inventoryTag, message: "Inventory updated - Product: \(productId), Quantity: \(newQuantity)")
    }
    
    func inventoryLow(productId: String, quantity: Int, threshold: Int) {
        logger.warning(tag: inventoryTag, message: "Low inventory alert - Product: \(productId), Current: \(quantity), Threshold: \(threshold)")
    }
}

// Custom tags for e-commerce app
struct UserTag: LogTag {
    let subsystem = Bundle.main.bundleIdentifier ?? "com.example.ecommerce"
    let category = "User"
}

struct CartTag: LogTag {
    let subsystem = Bundle.main.bundleIdentifier ?? "com.example.ecommerce"
    let category = "Cart"
}

struct OrderTag: LogTag {
    let subsystem = Bundle.main.bundleIdentifier ?? "com.example.ecommerce"
    let category = "Order"
}

struct PaymentTag: LogTag {
    let subsystem = Bundle.main.bundleIdentifier ?? "com.example.ecommerce"
    let category = "Payment"
}

struct InventoryTag: LogTag {
    let subsystem = Bundle.main.bundleIdentifier ?? "com.example.ecommerce"
    let category = "Inventory"
}

// Usage throughout the app
ECommerceLogger.shared.userLoggedIn(userId: "user123")
ECommerceLogger.shared.itemAddedToCart(productId: "prod456", userId: "user123")
ECommerceLogger.shared.paymentProcessed(orderId: "order789", amount: 99.99, method: "Credit Card")
```

### API Client with Comprehensive Logging

```swift
import Beaver

class APIClient {
    private let logger: BeaverLogger
    private let networkTag = NetworkTag()
    
    init() {
        self.logger = BeaverLoggerBuilder()
            .setLogLevel(.debug)
            .addLogSink(ConsoleLogSink())
            .build()
    }
    
    func fetchUser(id: String) async throws -> User {
        logger.info(tag: networkTag, message: "Fetching user with ID: \(id)")
        
        let startTime = Date()
        
        do {
            let url = URL(string: "https://api.example.com/users/\(id)")!
            let (data, response) = try await URLSession.shared.data(from: url)
            
            let duration = Date().timeIntervalSince(startTime)
            logger.debug(tag: networkTag, message: "API request completed in \(String(format: "%.2f", duration))s")
            
            if let httpResponse = response as? HTTPURLResponse {
                logger.debug(tag: networkTag, message: "Response status: \(httpResponse.statusCode)")
                
                if httpResponse.statusCode >= 400 {
                    logger.warning(tag: networkTag, message: "API returned error status: \(httpResponse.statusCode)")
                }
            }
            
            let user = try JSONDecoder().decode(User.self, from: data)
            logger.info(tag: networkTag, message: "Successfully decoded user: \(user.name)")
            
            return user
            
        } catch {
            let duration = Date().timeIntervalSince(startTime)
            logger.error(tag: networkTag, message: "API request failed after \(String(format: "%.2f", duration))s: \(error)")
            throw error
        }
    }
}

struct User: Codable {
    let id: String
    let name: String
    let email: String
}
```

## Best Practices

### 1. Use Appropriate Log Levels

```swift
// Debug: Detailed information for debugging
logger.debug("Cache miss for key: \(cacheKey)")

// Info: General application flow
logger.info("User session started")

// Warning: Potentially harmful situations
logger.warning("API response time: \(responseTime)ms exceeds threshold")

// Error: Error events that might affect functionality
logger.error("Failed to save user data: \(error)")
```

### 2. Leverage Lazy Evaluation

```swift
// Good: Uses @autoclosure for lazy evaluation
logger.debug("Expensive calculation result: \(performExpensiveCalculation())")

// Also good: Manual check for expensive operations
if logger.isLoggingEnabled(for: .debug) {
    let result = performExpensiveCalculation()
    logger.debug("Expensive calculation result: \(result)")
}
```

### 3. Create Domain-Specific Tags

```swift
// Organize by feature or subsystem
struct AuthenticationTag: LogTag {
    let subsystem = "com.yourapp"
    let category = "Authentication"
}

struct DatabaseTag: LogTag {
    let subsystem = "com.yourapp"  
    let category = "Database"
}

struct NetworkTag: LogTag {
    let subsystem = "com.yourapp"
    let category = "Network"
}
```

### 4. Configure Early in App Lifecycle

```swift
// In your App delegate or main app file
class AppDelegate: UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        configureLogging()
        
        return true
    }
    
    private func configureLogging() {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let logFileURL = documentsURL.appendingPathComponent("app.log")
        
        let logger = BeaverLoggerBuilder()
            .setLogLevel(.info)  // Adjust for production
            .addLogSink(ConsoleLogSink())
            .addLogSink(FileLogSink(fileURL: logFileURL))
            .build()
        
        // Store reference for app-wide use
        LoggingManager.shared.configure(with: logger)
    }
}
```

## Testing

### Mock Log Sink for Unit Tests

```swift
import Beaver

class MockLogSink: LogSink {
    var loggedMessages: [(String, LogLevel, LogTag?)] = []
    
    func write(_ message: String, level: LogLevel, tag: LogTag?) {
        loggedMessages.append((message, level, tag))
    }
    
    func clearLogs() {
        loggedMessages.removeAll()
    }
    
    func containsMessage(_ message: String, level: LogLevel? = nil) -> Bool {
        return loggedMessages.contains { logEntry in
            let messageMatches = logEntry.0.contains(message)
            let levelMatches = level == nil || logEntry.1 == level
            return messageMatches && levelMatches
        }
    }
    
    func messagesForLevel(_ level: LogLevel) -> [String] {
        return loggedMessages
            .filter { $0.1 == level }
            .map { $0.0 }
    }
}

// Usage in tests
import XCTest

class UserServiceTests: XCTestCase {
    var mockSink: MockLogSink!
    var logger: BeaverLogger!
    var userService: UserService!
    
    override func setUp() {
        super.setUp()
        
        mockSink = MockLogSink()
        logger = BeaverLoggerBuilder()
            .addLogSink(mockSink)
            .build()
        
        userService = UserService(logger: logger)
    }
    
    func testUserLogin() {
        // When
        userService.login(username: "testuser", password: "password")
        
        // Then
        XCTAssertTrue(mockSink.containsMessage("User login attempt", level: .info))
        XCTAssertTrue(mockSink.containsMessage("Login successful", level: .info))
        
        let infoMessages = mockSink.messagesForLevel(.info)
        XCTAssertEqual(infoMessages.count, 2)
    }
    
    func testUserLoginFailure() {
        // When
        userService.login(username: "testuser", password: "wrongpassword")
        
        // Then
        XCTAssertTrue(mockSink.containsMessage("Login failed", level: .error))
    }
}
```

## Performance Considerations

### Production Configuration

```swift
// Production logging configuration
let logger = BeaverLoggerBuilder()
    .setLogLevel(.warning)  // Only warnings and errors in production
    .addLogSink(FileLogSink(fileURL: logFileURL))
    .addLogSink(NetworkLogSink(endpoint: analyticsEndpoint))
    .build()
```

### Development Configuration

```swift
// Development logging configuration
let logger = BeaverLoggerBuilder()
    .setLogLevel(.debug)  // All levels during development
    .addLogSink(ConsoleLogSink())
    .addLogSink(FileLogSink(fileURL: logFileURL))
    .build()
```

### Conditional Compilation

```swift
#if DEBUG
let logLevel: LogLevel = .debug
#else
let logLevel: LogLevel = .warning
#endif

let logger = BeaverLoggerBuilder()
    .setLogLevel(logLevel)
    .addLogSink(ConsoleLogSink())
    .build()
```

---

This guide covers comprehensive usage patterns for the Beaver logging framework, from basic setup to advanced real-world applications.
