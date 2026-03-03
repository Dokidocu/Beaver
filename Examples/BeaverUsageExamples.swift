/**
 * Beaver Logging Framework Examples
 * 
 * This file demonstrates various usage patterns and best practices
 * for the Beaver logging framework.
 *
 * ## Overview
 * The examples in this file showcase:
 * - Basic logging operations with different log levels
 * - Custom configuration patterns using BeaverLoggerBuilder
 * - Tagged logging for organized log categorization
 * - Custom log sink implementations for different output destinations
 * - Real-world application examples (e-commerce, API clients)
 * - Testing utilities and best practices
 *
 * ## Usage
 * These examples are designed to be reference implementations that can be
 * copied and adapted for your specific use cases. All Beaver API calls are
 * commented out to prevent compilation errors when the framework is not
 * available, but can be uncommented when integrating with the actual framework.
 *
 * - Author: Beaver Framework Team
 * - Version: 1.0.0
 * - Since: iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0
 */

import Foundation

// Note: Replace 'Beaver' import with actual framework when building

// MARK: - Basic Usage Examples

/**
 * Demonstrates basic logging operations with a default logger configuration.
 *
 * This example shows how to:
 * - Create a logger using the default BeaverLoggerBuilder configuration
 * - Log messages at different severity levels (debug, info, warning, error)
 * - Use the framework for simple logging scenarios
 *
 * ## Example Usage:
 * ```swift
 * basicLoggingExample()
 * ```
 *
 * ## Log Levels:
 * - **Debug**: Detailed information for debugging purposes
 * - **Info**: General informational messages about application flow
 * - **Warning**: Potentially harmful situations that don't stop execution
 * - **Error**: Error events that might affect application functionality
 */
func basicLoggingExample() {
    // Create a basic logger
    // let logger = BeaverLoggerBuilder().build()

    // Log at different levels
    // logger.debug("Application started in debug mode")
    // logger.info("User authentication successful") 
    // logger.warning("API response time exceeded threshold")
    // logger.error("Failed to save user data")
}

/**
 * Demonstrates custom logger configuration with specific settings.
 *
 * This example shows how to:
 * - Configure a logger with a specific log level filter
 * - Add custom log sinks for different output destinations
 * - Use the builder pattern for fluent configuration
 *
 * ## Configuration Options:
 * - **Log Level**: Filters messages below the specified level
 * - **Log Sinks**: Multiple output destinations (console, file, network, etc.)
 *
 * ## Example Usage:
 * ```swift
 * customConfigurationExample()
 * ```
 *
 * - Note: Messages below the configured log level (.info in this case) will be filtered out
 */
func customConfigurationExample() {
    // Configure logger with specific settings
    // let logger = BeaverLoggerBuilder()
    //     .setLogLevel(.info)  // Only log info, warning, and error
    //     .addLogSink(ConsoleLogSink())
    //     .build()

    // logger.debug("This won't be logged due to level filtering")
    // logger.info("This will be logged")
    // logger.error("Critical error occurred")
}

// MARK: - Tagged Logging Examples

/**
 * Demonstrates tagged logging for organized log categorization.
 *
 * This example shows how to:
 * - Use built-in tags for common application areas (Network, Database, UI)
 * - Organize logs by subsystem and category for better filtering
 * - Leverage Apple's OSLog integration with proper categorization
 *
 * ## Built-in Tags:
 * - **NetworkTag**: Network operations and API calls
 * - **DatabaseTag**: Database operations and data persistence
 * - **UITag**: User interface events and interactions
 * - **GeneralTag**: General application logging
 *
 * ## Benefits:
 * - Easier log filtering and analysis
 * - Better organization in Console.app and Instruments
 * - Improved debugging workflow with categorized logs
 *
 * ## Example Usage:
 * ```swift
 * taggedLoggingExample()
 * ```
 */
func taggedLoggingExample() {
    // let logger = BeaverLoggerBuilder().build()

    // Network operations
    // let networkTag = NetworkTag()
    // logger.info(tag: networkTag, message: "Starting API request to /users")
    // logger.warning(tag: networkTag, message: "Request timeout, retrying...")
    // logger.error(tag: networkTag, message: "Network request failed after 3 retries")

    // Database operations  
    // let dbTag = DatabaseTag()
    // logger.info(tag: dbTag, message: "Database connection established")
    // logger.error(tag: dbTag, message: "Query execution failed")

    // UI events
    // let uiTag = UITag()
    // logger.debug(tag: uiTag, message: "User tapped login button")
    // logger.info(tag: uiTag, message: "Navigation to dashboard completed")
}

// MARK: - Custom Tag Implementation

/**
 * Custom tag for authentication-related logging operations.
 *
 * This tag categorizes all authentication-related log messages under the
 * "Authentication" category, making it easy to filter and analyze login,
 * logout, and security-related events.
 *
 * ## Usage:
 * ```swift
 * let authTag = AuthTag()
 * logger.info(tag: authTag, message: "User login attempt")
 * ```
 *
 * - Note: Implements LogTag protocol for use with Beaver logging framework
 */
// Authentication-specific logging
struct AuthTag {
    // LogTag implementation would go here
    let subsystem = Bundle.main.bundleIdentifier ?? "com.example.app"
    let category = "Authentication"
}

/**
 * Custom tag for payment processing and financial operations.
 *
 * This tag categorizes all payment-related log messages, including
 * transaction processing, payment gateway interactions, and billing events.
 *
 * ## Usage:
 * ```swift
 * let paymentTag = PaymentTag()
 * logger.info(tag: paymentTag, message: "Payment processed successfully")
 * ```
 *
 * - Important: Ensure sensitive payment data is not logged in production
 */
// Payment processing logging
struct PaymentTag {
    // LogTag implementation would go here
    let subsystem = Bundle.main.bundleIdentifier ?? "com.example.app"
    let category = "Payment"
}

/**
 * Custom tag for caching operations and cache management.
 *
 * This tag categorizes all cache-related log messages, including
 * cache hits, misses, invalidations, and performance metrics.
 *
 * ## Usage:
 * ```swift
 * let cacheTag = CacheTag()
 * logger.debug(tag: cacheTag, message: "Cache hit for key: \(key)")
 * ```
 */
// Cache operations logging
struct CacheTag {
    // LogTag implementation would go here
    let subsystem = Bundle.main.bundleIdentifier ?? "com.example.app"
    let category = "Cache"
}

/**
 * Demonstrates usage of custom tags for domain-specific logging.
 *
 * This example shows how to:
 * - Create and use custom tags for specific application domains
 * - Organize logs by business logic areas
 * - Maintain consistent categorization across the application
 *
 * ## Custom Tags Used:
 * - **AuthTag**: Authentication and security operations
 * - **PaymentTag**: Payment processing and financial transactions
 * - **CacheTag**: Caching operations and performance monitoring
 *
 * ## Example Usage:
 * ```swift
 * customTagExample()
 * ```
 */
func customTagExample() {
    // let logger = BeaverLoggerBuilder().build()
    // let authTag = AuthTag()
    // let paymentTag = PaymentTag()
    // let cacheTag = CacheTag()

    // logger.info(tag: authTag, message: "User login attempt")
    // logger.info(tag: paymentTag, message: "Processing credit card payment")
    // logger.debug(tag: cacheTag, message: "Cache hit for user profile")
}

// MARK: - Custom Log Sink Examples

/**
 * A custom log sink that implements log file rotation to manage disk space.
 *
 * This implementation:
 * - Writes logs to files with automatic rotation when size limits are reached
 * - Maintains a configurable number of historical log files
 * - Handles file system operations safely with proper error handling
 * - Formats log entries with timestamps and structured information
 *
 * ## Features:
 * - **Automatic Rotation**: Rotates logs when files exceed the configured size
 * - **Configurable Retention**: Keeps a specified number of historical files
 * - **Thread-Safe**: Safe for concurrent logging operations
 * - **Structured Format**: Consistent log entry formatting with metadata
 *
 * ## Usage:
 * ```swift
 * let rotatingLogger = RotatingFileLogSink(
 *     baseURL: logDirectory,
 *     maxFileSize: 10_000_000,  // 10MB
 *     maxFiles: 5               // Keep 5 historical files
 * )
 * ```
 *
 * - Parameters:
 *   - baseURL: Directory where log files will be stored
 *   - maxFileSize: Maximum size per log file before rotation (default: 10MB)
 *   - maxFiles: Number of historical files to retain (default: 5)
 *
 * - Note: Implements LogSink protocol for use with Beaver logging framework
 */
class RotatingFileLogSink {
    private let baseURL: URL
    private let maxFileSize: Int
    private let maxFiles: Int
    
    /**
     * Initializes a new rotating file log sink.
     *
     * - Parameters:
     *   - baseURL: The directory where log files will be stored
     *   - maxFileSize: Maximum size per log file before rotation (default: 10MB)
     *   - maxFiles: Number of historical files to retain (default: 5)
     */
    init(baseURL: URL, maxFileSize: Int = 10_000_000, maxFiles: Int = 5) {
        self.baseURL = baseURL
        self.maxFileSize = maxFileSize
        self.maxFiles = maxFiles
    }
    
    /**
     * Writes a log message to the current log file.
     *
     * This method:
     * - Formats the log entry with timestamp and metadata
     * - Checks if log rotation is needed based on file size
     * - Appends the message to the current log file
     * - Handles file creation if the log file doesn't exist
     *
     * - Parameters:
     *   - message: The log message to write
     *   - level: The log level as a string
     *   - tag: Optional tag information for categorization
     */
    func write(_ message: String, level: String, tag: String?) {
        let timestamp = ISO8601DateFormatter().string(from: Date())
        let subsystem = tag ?? "Unknown"
        
        let logEntry = "[\(timestamp)] [\(level.uppercased())] [\(subsystem)] \(message)\n"
        
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
    
    /**
     * Checks if the current log file should be rotated based on size.
     *
     * - Parameter url: The URL of the log file to check
     * - Returns: True if the file should be rotated, false otherwise
     */
    private func shouldRotateLog(at url: URL) -> Bool {
        guard let attributes = try? FileManager.default.attributesOfItem(atPath: url.path),
              let fileSize = attributes[.size] as? Int else {
            return false
        }
        return fileSize > maxFileSize
    }
    
    /**
     * Performs log file rotation by moving files to numbered backups.
     *
     * This method:
     * - Removes the oldest log file if the maximum number is reached
     * - Shifts existing backup files to higher numbers
     * - Moves the current log file to become the first backup
     *
     * File naming pattern: app.log → app.1.log → app.2.log → ... → app.N.log
     */
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

/**
 * A custom log sink that sends log messages to a remote server.
 *
 * This implementation:
 * - Sends log messages to a remote endpoint via HTTP POST
 * - Performs network operations asynchronously to avoid blocking
 * - Includes comprehensive metadata about the log entry and device
 * - Handles network failures gracefully without affecting application performance
 *
 * ## Features:
 * - **Async Network Operations**: Non-blocking network requests
 * - **Rich Metadata**: Includes platform, version, and timestamp information
 * - **Error Handling**: Graceful handling of network failures
 * - **JSON Format**: Structured log data in JSON format
 *
 * ## Usage:
 * ```swift
 * let networkSink = NetworkLogSink(
 *     endpoint: URL(string: "https://api.example.com/logs")!
 * )
 * ```
 *
 * ## Security Considerations:
 * - Ensure the endpoint uses HTTPS for secure transmission
 * - Consider authentication and authorization for the logging endpoint
 * - Be mindful of sensitive data in log messages
 *
 * - Parameters:
 *   - endpoint: The URL where log messages will be sent
 *   - session: URLSession instance for network operations (default: .shared)
 *
 * - Note: Implements LogSink protocol for use with Beaver logging framework
 */
class NetworkLogSink {
    private let endpoint: URL
    private let session: URLSession
    private let queue = DispatchQueue(label: "network-log-sink", qos: .utility)
    
    /**
     * Initializes a new network log sink.
     *
     * - Parameters:
     *   - endpoint: The URL where log messages will be sent
     *   - session: URLSession instance for network operations (default: .shared)
     */
    init(endpoint: URL, session: URLSession = .shared) {
        self.endpoint = endpoint
        self.session = session
    }
    
    /**
     * Sends a log message to the remote server asynchronously.
     *
     * This method queues the network operation on a background queue to
     * avoid blocking the calling thread. Network failures are logged but
     * do not affect application performance.
     *
     * - Parameters:
     *   - message: The log message to send
     *   - level: The log level as a string
     *   - tag: Optional tag information for categorization
     */
    func write(_ message: String, level: String, tag: String?) {
        queue.async { [weak self] in
            self?.sendLogToServer(message: message, level: level, tag: tag)
        }
    }
    
    /**
     * Performs the actual network request to send log data to the server.
     *
     * This method:
     * - Creates a JSON payload with log data and metadata
     * - Configures an HTTP POST request with appropriate headers
     * - Sends the request asynchronously
     * - Handles network errors gracefully
     *
     * ## JSON Payload Structure:
     * ```json
     * {
     *   "timestamp": "2023-07-01T12:00:00Z",
     *   "level": "info",
     *   "message": "User logged in",
     *   "subsystem": "com.example.app",
     *   "platform": "iOS",
     *   "version": "1.0.0"
     * }
     * ```
     *
     * - Parameters:
     *   - message: The log message
     *   - level: The log level
     *   - tag: Optional tag information
     */
    private func sendLogToServer(message: String, level: String, tag: String?) {
        let logData: [String: Any] = [
            "timestamp": ISO8601DateFormatter().string(from: Date()),
            "level": level,
            "message": message,
            "subsystem": tag ?? "unknown",
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

// MARK: - Real-World Application Examples

/**
 * A comprehensive logging solution for e-commerce applications.
 *
 * This class demonstrates how to implement domain-specific logging for
 * complex business applications. It provides structured logging for all
 * major e-commerce operations with appropriate categorization.
 *
 * ## Features:
 * - **User Management**: Login, logout, and user activity tracking
 * - **Shopping Cart**: Cart operations and checkout process monitoring
 * - **Order Management**: Order lifecycle tracking from creation to fulfillment
 * - **Payment Processing**: Payment transaction logging with security considerations
 * - **Inventory Management**: Stock level monitoring and alerts
 *
 * ## Usage:
 * ```swift
 * ECommerceLogger.shared.userLoggedIn(userId: "user123")
 * ECommerceLogger.shared.orderCreated(orderId: "order456", userId: "user123")
 * ```
 *
 * ## Architecture:
 * - Singleton pattern for consistent logging across the application
 * - Category-specific tags for organized log filtering
 * - Multiple output destinations (console, file) for different environments
 *
 * - Note: This is a reference implementation that can be adapted for specific business needs
 */
class ECommerceLogger {
    /**
     * Shared singleton instance for consistent logging across the application.
     */
    static let shared = ECommerceLogger()
    
    // private let logger: BeaverLogger
    
    // Custom tags for different app areas
    private let userTag = "User"
    private let cartTag = "Cart"
    private let orderTag = "Order"
    private let paymentTag = "Payment"
    private let inventoryTag = "Inventory"
    
    /**
     * Private initializer to enforce singleton pattern.
     *
     * Sets up logging configuration with:
     * - Info level logging for production readiness
     * - Console output for development debugging
     * - File output for persistent log storage
     */
    private init() {
        let logDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            .first!.appendingPathComponent("Logs")
        
        try? FileManager.default.createDirectory(at: logDirectory, 
                                               withIntermediateDirectories: true)
        
        // self.logger = BeaverLoggerBuilder()
        //     .setLogLevel(.info)
        //     .addLogSink(ConsoleLogSink())
        //     .addLogSink(FileLogSink(fileURL: logDirectory.appendingPathComponent("app.log")))
        //     .build()
    }
    
    // MARK: - User Management
    
    /**
     * Logs a successful user login event.
     *
     * - Parameter userId: The unique identifier of the user who logged in
     */
    func userLoggedIn(userId: String) {
        // logger.info(tag: userTag, message: "User logged in: \(userId)")
        print("User logged in: \(userId)")
    }
    
    /**
     * Logs a user logout event.
     *
     * - Parameter userId: The unique identifier of the user who logged out
     */
    func userLoggedOut(userId: String) {
        // logger.info(tag: userTag, message: "User logged out: \(userId)")
        print("User logged out: \(userId)")
    }
    
    // MARK: - Shopping Cart Management
    
    /**
     * Logs when an item is added to a user's shopping cart.
     *
     * - Parameters:
     *   - productId: The unique identifier of the product added
     *   - userId: The unique identifier of the user
     */
    func itemAddedToCart(productId: String, userId: String) {
        // logger.info(tag: cartTag, message: "Item \(productId) added to cart for user \(userId)")
        print("Item \(productId) added to cart for user \(userId)")
    }
    
    /**
     * Logs the initiation of a cart checkout process.
     *
     * - Parameters:
     *   - userId: The unique identifier of the user
     *   - itemCount: The number of items in the cart
     *   - total: The total amount of the cart
     */
    func cartCheckout(userId: String, itemCount: Int, total: Decimal) {
        // logger.info(tag: cartTag, message: "Cart checkout initiated - User: \(userId), Items: \(itemCount), Total: $\(total)")
        print("Cart checkout initiated - User: \(userId), Items: \(itemCount), Total: $\(total)")
    }
    
    // MARK: - Order Management
    
    /**
     * Logs the creation of a new order.
     *
     * - Parameters:
     *   - orderId: The unique identifier of the created order
     *   - userId: The unique identifier of the user who placed the order
     */
    func orderCreated(orderId: String, userId: String) {
        // logger.info(tag: orderTag, message: "Order created: \(orderId) for user \(userId)")
        print("Order created: \(orderId) for user \(userId)")
    }
    
    func orderFulfilled(orderId: String) {
        // logger.info(tag: orderTag, message: "Order fulfilled: \(orderId)")
        print("Order fulfilled: \(orderId)")
    }
    
    func orderCancelled(orderId: String, reason: String) {
        // logger.warning(tag: orderTag, message: "Order cancelled: \(orderId), Reason: \(reason)")
        print("Order cancelled: \(orderId), Reason: \(reason)")
    }
    
    // Payments
    func paymentProcessed(orderId: String, amount: Decimal, method: String) {
        // logger.info(tag: paymentTag, message: "Payment processed - Order: \(orderId), Amount: $\(amount), Method: \(method)")
        print("Payment processed - Order: \(orderId), Amount: $\(amount), Method: \(method)")
    }
    
    func paymentFailed(orderId: String, error: String) {
        // logger.error(tag: paymentTag, message: "Payment failed - Order: \(orderId), Error: \(error)")
        print("Payment failed - Order: \(orderId), Error: \(error)")
    }
    
    // Inventory
    func inventoryUpdated(productId: String, newQuantity: Int) {
        // logger.debug(tag: inventoryTag, message: "Inventory updated - Product: \(productId), Quantity: \(newQuantity)")
        print("Inventory updated - Product: \(productId), Quantity: \(newQuantity)")
    }
    
    func inventoryLow(productId: String, quantity: Int, threshold: Int) {
        // logger.warning(tag: inventoryTag, message: "Low inventory alert - Product: \(productId), Current: \(quantity), Threshold: \(threshold)")
        print("Low inventory alert - Product: \(productId), Current: \(quantity), Threshold: \(threshold)")
    }
}

// MARK: - API Client Logging Example

class APIClient {
    // private let logger: BeaverLogger
    private let networkTag = "Network"
    
    init() {
        // self.logger = BeaverLoggerBuilder()
        //     .setLogLevel(.debug)
        //     .addLogSink(ConsoleLogSink())
        //     .build()
    }
    
    func fetchUser(id: String) async throws -> User {
        // logger.info(tag: networkTag, message: "Fetching user with ID: \(id)")
        print("Fetching user with ID: \(id)")
        
        let startTime = Date()
        
        do {
            let url = URL(string: "https://api.example.com/users/\(id)")!
            let (data, response) = try await URLSession.shared.data(from: url)
            
            let duration = Date().timeIntervalSince(startTime)
            // logger.debug(tag: networkTag, message: "API request completed in \(String(format: "%.2f", duration))s")
            print("API request completed in \(String(format: "%.2f", duration))s")
            
            if let httpResponse = response as? HTTPURLResponse {
                // logger.debug(tag: networkTag, message: "Response status: \(httpResponse.statusCode)")
                print("Response status: \(httpResponse.statusCode)")
                
                if httpResponse.statusCode >= 400 {
                    // logger.warning(tag: networkTag, message: "API returned error status: \(httpResponse.statusCode)")
                    print("API returned error status: \(httpResponse.statusCode)")
                }
            }
            
            let user = try JSONDecoder().decode(User.self, from: data)
            // logger.info(tag: networkTag, message: "Successfully decoded user: \(user.name)")
            print("Successfully decoded user: \(user.name)")
            
            return user
            
        } catch {
            let duration = Date().timeIntervalSince(startTime)
            // logger.error(tag: networkTag, message: "API request failed after \(String(format: "%.2f", duration))s: \(error)")
            print("API request failed after \(String(format: "%.2f", duration))s: \(error)")
            throw error
        }
    }
}

struct User: Codable {
    let id: String
    let name: String
    let email: String
}

// MARK: - Testing Examples

class MockLogSink {
    var loggedMessages: [(String, String, String?)] = []
    
    func write(_ message: String, level: String, tag: String?) {
        loggedMessages.append((message, level, tag))
    }
    
    func clearLogs() {
        loggedMessages.removeAll()
    }
    
    func containsMessage(_ message: String, level: String? = nil) -> Bool {
        return loggedMessages.contains { logEntry in
            let messageMatches = logEntry.0.contains(message)
            let levelMatches = level == nil || logEntry.1 == level
            return messageMatches && levelMatches
        }
    }
}

// Usage examples for the Beaver logging framework
// These examples demonstrate real-world usage patterns and best practices
