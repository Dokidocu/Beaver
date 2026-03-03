# Changelog

All notable changes to Beaver will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
- `LogMessage` — lazy `ExpressibleByStringInterpolation` type with built-in formatters for `Double` precision, arrays, dictionaries, optionals, `Codable` JSON, and `[String: Any]` JSON.
- `LogContext` — auto-captured call-site metadata via `#fileID`, `#function`, `#line`.
- Platforms: iOS 14+, macOS 11+, tvOS 14+, watchOS 7+.
- Swift Package Manager distribution.
