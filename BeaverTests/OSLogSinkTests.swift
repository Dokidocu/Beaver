import XCTest
import OSLog
@testable import Beaver

final class OSLogSinkTests: XCTestCase {
    private struct Emission: Equatable {
        let level: LogLevel
        let message: String
    }

    private final class EmissionRecorder: @unchecked Sendable {
        private var emissions: [Emission] = []
        private let lock = NSLock()

        func record(_ emission: Emission) {
            lock.withLock { emissions.append(emission) }
        }

        var lastEmission: Emission? {
            lock.withLock { emissions.last }
        }
    }

    private func makeSink(
        privacy: OSLogPrivacyMode = .private,
        recorder: EmissionRecorder
    ) -> OSLogSink {
        OSLogSink(sourceFormat: .compact, privacy: privacy) { _, level, message in
            recorder.record(.init(level: level, message: message))
        }
    }

    private func makeTag() -> LogTag {
        LogTag(subsystem: "com.example.app", prefix: "NET", name: "Network")
    }

    private func makeContext() -> LogContext {
        LogContext(file: "Feature.swift", function: "run()", line: 23)
    }

    func testWriteLogRedactsInheritedInterpolationWhenDefaultPrivacyIsPrivate() throws {
        // GIVEN an OSLog sink created with the default privacy mode
        let recorder = EmissionRecorder()
        let sink = makeSink(recorder: recorder)

        // WHEN  the sink writes a log entry
        sink.writeLog(
            logLevel: .info,
            logTag: makeTag(),
            message: "Signed in user \("alice@example.com")",
            context: makeContext()
        )

        // THEN  only the interpolated value is redacted
        XCTAssertEqual(
            try XCTUnwrap(recorder.lastEmission),
            Emission(level: .info, message: "[INFO] [Network] Feature.swift:23: Signed in user <private>")
        )
    }

    func testWriteLogCanOptIntoPublicPrivacyForInheritedInterpolation() throws {
        // GIVEN an OSLog sink configured for public visibility
        let recorder = EmissionRecorder()
        let sink = makeSink(privacy: .public, recorder: recorder)

        // WHEN  the sink writes a log entry
        sink.writeLog(
            logLevel: .error,
            logTag: makeTag(),
            message: "Signed in user \("alice@example.com")",
            context: makeContext()
        )

        // THEN  the inherited interpolation remains visible
        XCTAssertEqual(
            try XCTUnwrap(recorder.lastEmission),
            Emission(level: .error, message: "[ERROR] [Network] Feature.swift:23: Signed in user alice@example.com")
        )
    }

    func testWriteLogExplicitPrivateInterpolationOverridesPublicSinkDefault() throws {
        // GIVEN a public OSLog sink and a message with explicit private interpolation
        let recorder = EmissionRecorder()
        let sink = makeSink(privacy: .public, recorder: recorder)

        // WHEN  the sink writes that entry
        sink.writeLog(
            logLevel: .info,
            logTag: makeTag(),
            message: "Build \(public: "Debug") for \(private: "alice@example.com")",
            context: makeContext()
        )

        // THEN  explicit private values are still redacted
        XCTAssertEqual(
            try XCTUnwrap(recorder.lastEmission),
            Emission(level: .info, message: "[INFO] [Network] Feature.swift:23: Build Debug for <private>")
        )
    }
}
