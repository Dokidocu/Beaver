# Changelog

All notable changes to Beaver will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.2.0] - 2026-04-27

### Added

- Added `OSLogPrivacyMode` so callers can choose between sink-level `.private` and `.public` OSLog visibility.
- Added privacy-aware interpolation labels such as `\(private: value)`, `\(public: value)`, and `\(privateJSON: payload)` for field-level redaction in `OSLogSink`.
- Added lazy log-message evaluation via `@autoclosure`-based logging APIs, so filtered-out message expressions are not constructed.
- Added configurable `OSLogSink` source formatting with `LogSourceFormat.full`, `.compact`, and `.none`.
- Updated the default `OSLogSink` message format to include the tag in the rendered output and use compact source formatting: `[LEVEL] [TAG] File.swift:line: message`.
- Made plain dictionary interpolation deterministic by sorting entries lexicographically by displayed key text.

### Changed

- Changed `OSLogSink` so `.private` is now the default privacy for unannotated interpolated values, while literals remain visible and `OSLogSink(privacy: .public)` opts those unannotated interpolations into public output.

### Fixed

- Rewrote the DocC overview to reflect the shipped Beaver architecture and public API, including the current `Log`, `LogSink`, `LogTag`, and `OSLogSink` model.
- Fixed example code and mirrored usage snippets that previously contained invalid log-level string handling and mismatched example types.
- Clarified `USAGE.md` so built-in tag examples no longer reference the custom `payments` tag before it is introduced.
- Corrected the README architecture summary so `LoggerState` is described as a short lock-protected facade load rather than as "lock-free reads."

## [1.1.0] - 2026-03-10

### Fixed

- Removed extraneous blank line after opening brace in `Log.swift` (SwiftLint `vertical_whitespace_opening_braces`).
- Split test classes into one file each to satisfy SwiftLint `single_test_class` rule (`LoggerFacadeTests.swift`, `LogNonisolatedTests.swift`, `LogIntegrationTests.swift`).
- Converted `LoggerCache` from a namespace `enum` to a `final class` singleton (`@unchecked Sendable`) to resolve Swift 6 strict-concurrency error on the internal `os.Logger` cache.
- Added explicit `Sendable` conformance to `Log.Configuration` to satisfy Swift 6 actor-boundary safety when passing a configuration value to `await Log.configure(_:)`.

## [1.0.0] - 2026-03-03

### Added

- `Log` — Swift 6-compatible actor as the central logging entry point.
- `nonisolated` logging methods — call `Log.info(...)`, `Log.error(...)` etc. from any thread, actor, or `@MainActor` context with no `await`.
- Static convenience API: `Log.debug(...)`, `Log.info(...)`, `Log.warning(...)`, `Log.error(...)`.
- `Log.configure(_:)` for one-time startup configuration (minimum level + sinks). This is the only `async` call in the public API.
- `LogSink` protocol (`Sendable`) — implement to route logs to any destination (file, network, analytics, etc.).
- `OSLogSink` — built-in sink bridging to `os.Logger` with per-subsystem/category `Logger` caching.
- `LogTags` — predefined tags: `general`, `lifecycle`, `performance`, `network`, `api`, `auth`, `oauth`, `ui`, `accessibility`.
- `LogTag` — `Equatable`, `Hashable`, and `Sendable`; suitable as dictionary keys.
- `LogLevel` — `Comparable` enum: `.debug`, `.info`, `.warning`, `.error`.
- `LogMessage` — `ExpressibleByStringInterpolation` type with built-in formatters for `Double` precision, arrays, dictionaries, optionals, `Codable` JSON, and `[String: Any]` JSON.
- `LogContext` — auto-captured call-site metadata via `#fileID`, `#function`, `#line`.
- Platforms: iOS 14+, macOS 11+, tvOS 14+, watchOS 7+.
- Swift Package Manager distribution.
