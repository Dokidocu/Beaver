import Foundation

/**
 * LogTag defines the protocol for log categorization and organization in the Beaver framework.
 *
 * This protocol enables structured logging by providing subsystem and category
 * information that helps organize and filter log messages. It integrates
 * seamlessly with Apple's OSLog system to provide proper categorization
 * in Console.app, Instruments, and other debugging tools.
 *
 * ## Key Features
 *
 * ### Structured Organization
 * - **Subsystem**: Groups related functionality (usually bundle identifier)
 * - **Category**: Specific feature or module within the subsystem
 * - **Prefix**: Formatted string for log message decoration
 *
 * ### OSLog Integration
 * - Maps directly to OSLog subsystem and category parameters
 * - Enables proper filtering and organization in Apple's tools
 * - Maintains consistency across logging destinations
 *
 * ### Flexible Implementation
 * - Protocol-based design allows custom implementations
 * - Default implementations reduce boilerplate code
 * - Extensible for domain-specific requirements
 *
 * ## Usage Examples
 *
 * ### Basic Tag Implementation
 * ```swift
 * struct NetworkTag: LogTag {
 *     let name = "Network"
 *     // subsystem and prefix use default implementations
 * }
 *
 * struct DatabaseTag: LogTag {
 *     let name = "Database"
 *     let subsystem = "com.myapp.core"  // Custom subsystem
 * }
 * ```
 *
 * ### Custom Tag with Formatting
 * ```swift
 * struct APITag: LogTag {
 *     let endpoint: String
 *
 *     var name: String { "API-\(endpoint)" }
 *     var prefix: String { "[🌐 \(name)] " }  // Custom emoji prefix
 * }
 * ```
 *
 * ### Using Tags with Logger
 * ```swift
 * let networkTag = NetworkTag()
 * let dbTag = DatabaseTag()
 *
 * logger.info(tag: networkTag, message: "Request started")
 * logger.error(tag: dbTag, message: "Connection failed")
 * ```
 *
 * ## Default Implementations
 *
 * The protocol provides sensible defaults that work for most use cases:
 *
 * - **subsystem**: Uses `Bundle.main.bundleIdentifier` or fallback
 * - **prefix**: Creates formatted prefix like "[NETWORK] " from the name
 *
 * ## Best Practices
 *
 * ### Naming Conventions
 * - Use descriptive, consistent names for categories
 * - Consider hierarchical naming for related features
 * - Keep names concise but meaningful
 *
 * ### Subsystem Organization
 * - Use bundle identifier for app-level subsystems
 * - Consider separate subsystems for major components
 * - Maintain consistency across your application
 *
 * ### Performance Considerations
 * - Tag properties are accessed frequently during logging
 * - Consider caching expensive computations
 * - Prefer static strings over dynamic generation
 *
 * ## OSLog Mapping
 *
 * LogTag properties map directly to OSLog parameters:
 * - `subsystem` → OSLog subsystem parameter
 * - `name` → OSLog category parameter
 * - `prefix` → Used for message formatting in custom sinks
 *
 * This ensures consistency between Beaver's custom sinks and Apple's
 * unified logging system.
 *
 * - Important: Implementations must be thread-safe (Sendable conformance)
 * - Note: Default implementations reduce implementation overhead
 * - Version: 1.0.0
 * - Since: iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0
 */
public protocol LogTag: Sendable {
    /**
     * The subsystem identifier for organizing related log categories.
     *
     * The subsystem typically represents a major component or the entire
     * application. It's used by OSLog to group related categories together
     * and provides the top-level organization for log filtering.
     *
     * ## Common Patterns:
     * - App bundle identifier: "com.company.appname"
     * - Framework identifier: "com.company.framework"
     * - Component identifier: "com.company.app.networking"
     *
     * - Returns: A string identifying the subsystem for this log category
     */
    var subsystem: String { get }
    
    /**
     * A formatted prefix string for decorating log messages.
     *
     * The prefix provides a visual indicator in log output that helps
     * identify the source category of log messages. It's primarily used
     * by custom log sinks for formatting purposes.
     *
     * ## Example Output:
     * - NetworkTag → "[NETWORK] "
     * - DatabaseTag → "[DATABASE] "
     * - Custom formatting → "[🌐 API] "
     *
     * - Returns: A formatted string prefix for log message decoration
     */
    var prefix: String { get }
    
    /**
     * The category name for this log tag.
     *
     * The category represents a specific feature, module, or functional
     * area within the subsystem. It provides fine-grained organization
     * and is used as the category parameter in OSLog.
     *
     * ## Naming Guidelines:
     * - Use descriptive, concise names
     * - Consider consistency across your application
     * - Examples: "Network", "Database", "UI", "Authentication"
     *
     * ## Usage in OSLog:
     * This value becomes the category parameter in OSLog logger creation
     *
     * - Returns: A string identifying the specific category for this tag
     */
    var name: String { get }
}
