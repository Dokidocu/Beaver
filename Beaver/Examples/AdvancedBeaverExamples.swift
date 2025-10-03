/*
 * Beaver Logging Framework Examples
 *
 * This file demonstrates various usage patterns and best practices 
 * for the Beaver logging framework.
 */

import Beaver
import Foundation

// MARK: - Basic Usage Examples

func basicLoggingExample() {
    // Create a basic logger
    let logger = BeaverLoggerBuilder().build()

    // Log at different levels
    logger.debug("Application started in debug mode")
    logger.info("User authentication successful")
    logger.warning("API response time exceeded threshold")
    logger.error("Failed to save user data")
}

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

## Tagged Logging Examples

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

// Cache operations logging
struct CacheTag: LogTag {
    let subsystem = Bundle.main.bundleIdentifier ?? "com.example.app"
    let category = "Cache"
}

// Usage
let logger = BeaverLoggerBuilder().build()
let authTag = AuthTag()
let paymentTag = PaymentTag()
let cacheTag = CacheTag()

logger.info(tag: authTag, message: "User login attempt")
logger.info(tag: paymentTag, message: "Processing credit card payment")
logger.debug(tag: cacheTag, message: "Cache hit for user profile")
```

## Custom Log Sink Examples

### File Logging Sink

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

### Network Logging Sink

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

### Filtered Console Sink

```swift
import Beaver
import Foundation

class FilteredConsoleSink: LogSink {
    private let allowedCategories: Set<String>
    private let minimumLevel: LogLevel
    
    init(allowedCategories: Set<String> = [], minimumLevel: LogLevel = .debug) {
        self.allowedCategories = allowedCategories
        self.minimumLevel = minimumLevel
    }
    
    func write(_ message: String, level: LogLevel, tag: LogTag?) {
        // Filter by level
        guard level.rawValue >= minimumLevel.rawValue else { return }
        
        // Filter by category if specified
        if !allowedCategories.isEmpty {
            guard let category = tag?.category,
                  allowedCategories.contains(category) else { return }
        }
        
        let timestamp = DateFormatter.consoleTimestamp.string(from: Date())
        let levelIcon = levelIcon(for: level)
        let categoryInfo = tag.map { "[\($0.category)]" } ?? ""
        
        print("\(timestamp) \(levelIcon) \(categoryInfo) \(message)")
    }
    
    private func levelIcon(for level: LogLevel) -> String {
        switch level {
        case .debug: return "🔍"
        case .info: return "ℹ️"
        case .warning: return "⚠️"
        case .error: return "❌"
        }
    }
}

extension DateFormatter {
    static let consoleTimestamp: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss.SSS"
        return formatter
    }()
}

// Usage - only log network and database categories
let filteredSink = FilteredConsoleSink(
    allowedCategories: ["Network", "Database"],
    minimumLevel: .info
)

let logger = BeaverLoggerBuilder()
    .addLogSink(filteredSink)
    .build()
```

## Real-World Application Examples

### E-commerce App Logging

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

### API Client Logging

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

## Performance Optimization Examples

### Expensive Log Message Construction

```swift
import Beaver

let logger = BeaverLoggerBuilder().build()

// Good: Uses @autoclosure for lazy evaluation
func processLargeDataset(_ data: [DataItem]) {
    logger.debug("Processing dataset: \(data.map { $0.debugDescription }.joined(separator: ", "))")
    
    // Process data...
    
    logger.info("Processed \(data.count) items successfully")
}

// Even better: Manual check for expensive operations
func processLargeDatasetOptimized(_ data: [DataItem]) {
    if logger.isLoggingEnabled(for: .debug) {
        let debugInfo = data.map { $0.debugDescription }.joined(separator: ", ")
        logger.debug("Processing dataset: \(debugInfo)")
    }
    
    // Process data...
    
    logger.info("Processed \(data.count) items successfully")
}

// Extension to check if logging is enabled for a level
extension BeaverLogger {
    func isLoggingEnabled(for level: LogLevel) -> Bool {
        // This would need to be implemented in the actual BeaverLogger class
        // For now, this is a conceptual example
        return true
    }
}
```

## Testing Examples

### Mock Log Sink for Testing

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
}

// Usage in tests
func testUserLogin() {
    let mockSink = MockLogSink()
    let logger = BeaverLoggerBuilder()
        .addLogSink(mockSink)
        .build()
    
    // Test user login functionality
    let userService = UserService(logger: logger)
    userService.login(username: "testuser", password: "password")
    
    // Verify logging occurred
    XCTAssertTrue(mockSink.containsMessage("User login attempt", level: .info))
    XCTAssertTrue(mockSink.containsMessage("Login successful", level: .info))
}
```

These examples demonstrate the flexibility and power of the Beaver logging framework across various real-world scenarios, from basic usage to complex enterprise applications.
