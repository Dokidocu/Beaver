import Foundation
import Beaver

// MARK: - Example Usage of Beaver Logging Framework

func demonstrateBeaverUsage() {
    // Basic configuration
    print("=== Basic Beaver Usage ===")
    
    // Simple logging with default configuration
    Beaver.debug("Application starting up...")
    Beaver.info("Configuration loaded successfully")
    Beaver.warning("Low memory warning received")
    Beaver.error("Failed to connect to server")
    
    // Configure Beaver with custom settings
    print("\n=== Custom Configuration ===")
    
    let consoleSink = ConsoleLogSink()
    
    // Configure with file logging if we have a writable directory
    if let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
        let logFileURL = documentsPath.appendingPathComponent("beaver.log")
        let fileSink = FileLogSink(fileURL: logFileURL)
        
        Beaver.configure(with: BeaverBuilder()
            .setLogLevel(.info)  // Filter out debug messages
            .addLogSink(consoleSink)
            .addLogSink(fileSink)
            .setSubsystem("com.example.beaver")
            .setCategory("Demo")
        )
        
        print("Configured Beaver with file logging at: \(logFileURL.path)")
    } else {
        Beaver.configure(with: BeaverBuilder()
            .setLogLevel(.info)
            .addLogSink(consoleSink)
            .setSubsystem("com.example.beaver")
            .setCategory("Demo")
        )
    }
    
    // Test filtering - debug should be filtered out
    Beaver.debug("This debug message should be filtered out")
    Beaver.info("This info message should appear")
    
    // Using different log tags
    print("\n=== Tagged Logging ===")
    
    let networkTag = NetworkTag()
    let dbTag = DatabaseTag()
    let uiTag = UITag()
    
    Beaver.info(tag: networkTag, message: "Starting API request to /users")
    Beaver.error(tag: networkTag, message: "API request failed with status 500")
    
    Beaver.info(tag: dbTag, message: "Connected to database successfully")
    Beaver.warning(tag: dbTag, message: "Database query took longer than expected")
    
    Beaver.info(tag: uiTag, message: "View controller loaded")
    Beaver.error(tag: uiTag, message: "Failed to update UI element")
    
    // Custom log tag example
    print("\n=== Custom Log Tag ===")
    
    struct PaymentTag: LogTag {
        var subsystem = "com.example.payments"
        var prefix = "[💳 PAY] "
        var name = "Payment"
    }
    
    let paymentTag = PaymentTag()
    Beaver.info(tag: paymentTag, message: "Processing payment for order #12345")
    Beaver.error(tag: paymentTag, message: "Payment failed: insufficient funds")
    
    // Demonstrate log level escalation
    print("\n=== Log Level Escalation ===")
    
    var level = LogLevel.debug
    print("Starting level: \(level.name)")
    
    level.escalate()
    print("After escalation: \(level.name)")
    
    level.escalate()
    print("After escalation: \(level.name)")
    
    level.escalate()
    print("After escalation: \(level.name)")
    
    level.escalate() // Should stay at error
    print("After escalation: \(level.name)")
}

// MARK: - Performance Testing

func performanceExample() {
    print("\n=== Performance Example ===")
    
    // Expensive operation that will only be executed if the log level allows it
    func expensiveStringOperation() -> String {
        print("Executing expensive string operation...")
        return "This took a lot of work to compute"
    }
    
    // Configure to only log errors
    Beaver.configure(with: BeaverBuilder().setLogLevel(.error))
    
    // This expensive operation won't be executed because debug is filtered out
    Beaver.debug("Debug: \(expensiveStringOperation())")
    print("The expensive operation was not executed!")
    
    // This will execute the expensive operation
    Beaver.error("Error: \(expensiveStringOperation())")
}
