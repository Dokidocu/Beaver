import Foundation

/// Centralized definitions for all log tags used by the application.
///
/// `LogTags` provides a curated set of reusable `LogTag` values that categorize log messages by feature area or concern. Tags are intended
/// to be stable, low in number, and shared across the codebase to ensure consistent log output and filtering.
///
/// Tags are grouped by domain (core application flow, networking, security, UI, etc.) and map cleanly to logging backends such as `os.Logger` via
/// their subsystem values.
///
/// - Note:
///   Log tags should represent *what part of the system* is emitting the log, not *what happened*. Message content should carry the details;
///   tags should remain coarse-grained.
///
/// - Important:
///   Avoid creating ad-hoc or highly specific tags. If a tag becomes too noisy or overloaded, consider splitting it into a more specific one.
public enum LogTags {
    private static let baseSubsystem =
        Bundle.main.bundleIdentifier
        ?? ProcessInfo.processInfo.processName

    // MARK: - Core

    /// High-level application flow and cross-cutting events.
    ///
    /// Use this tag for logs that describe the overall execution narrative of the application, such as major state transitions,
    /// flow milestones, or fallback/default logging.
    public static let general = LogTag(
        subsystem: baseSubsystem,
        prefix: "",
        name: "General"
    )

    /// Application and scene lifecycle events driven by the operating system.
    ///
    /// This tag is intended for OS-originated events such as application launch, foreground/background transitions, scene creation or
    /// destruction, and memory warnings.
    public static let lifecycle = LogTag(
        subsystem: baseSubsystem,
        prefix: "APP",
        name: "Lifecycle"
    )

    /// Performance and timing-related measurements.
   ///
   /// Use this tag for logs related to startup time, slow operations, execution duration, and other performance-relevant metrics.
    public static let performance = LogTag(
        subsystem: baseSubsystem,
        prefix: "📈",
        name: "Performance"
    )

    // MARK: - Networking

    /// Transport-level networking concerns.
    ///
    /// This tag covers connectivity, request lifecycle, retries, timeouts, reachability changes, and other low-level networking behavior.
    public static let network = LogTag(
        subsystem: "\(baseSubsystem).network",
        prefix: "🛜",
        name: "Network"
    )

    /// Backend API and contract-level concerns.
    ///
    /// Use this tag for endpoint-specific behavior, request/response handling, decoding, schema mismatches, and API-related errors.
    public static let api = LogTag(
        subsystem: "\(baseSubsystem).api",
        prefix: "API",
        name: "API"
    )

    // MARK: - Security

    /// Authentication and authorization state.
    ///
    /// This tag represents user authentication status, session state, access control decisions, and other identity-related application logic.
    public static let auth = LogTag(
        subsystem: "\(baseSubsystem).auth",
        prefix: "🔐",
        name: "Auth"
    )

    /// OAuth protocol and token lifecycle handling.
    ///
    /// Use this tag for OAuth-specific mechanics such as authorization flows, redirects, token exchange, refresh operations, and provider errors.
    public static let oauth = LogTag(
        subsystem: "\(baseSubsystem).oauth",
        prefix: "OAUTH",
        name: "OAuth"
    )

    // MARK: - UI

    /// User interface flow and presentation logic.
    ///
    /// This tag covers screen transitions, navigation decisions, and other UI-level behavior that is not tied to a specific feature.
    public static let ui = LogTag(
        subsystem: "\(baseSubsystem).ui",
        prefix: "UI",
        name: "UI"
    )

    /// Accessibility-related behavior and assistive technology support.
    ///
    /// Use this tag for logs related to VoiceOver, dynamic type, accessibility labels, traits, and other inclusive design considerations.
    public static let accessibility = LogTag(
        subsystem: "\(baseSubsystem).accessibility",
        prefix: "♿️",
        name: "Accessibility"
    )
}
