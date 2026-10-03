import Foundation

public struct FetchFailure: LocalizedError, Hashable, Sendable {
    public let message: String
    public let canRetry: Bool
    public let endsSession: Bool

    public var errorDescription: String? {
        message
    }

    public init(_ message: String, canRetry: Bool = true, endsSession: Bool = false) {
        self.message = message
        self.canRetry = canRetry
        self.endsSession = endsSession
    }

    public init(
        _ message: LocalizedStringResource,
        canRetry: Bool = true,
        endsSession: Bool = false
    ) {
        self.init(String(localized: message), canRetry: canRetry, endsSession: endsSession)
    }
}

public extension FetchFailure {
    static var offline: FetchFailure {
        FetchFailure(.screenOffline)
    }

    static var timeout: FetchFailure {
        FetchFailure(.screenTimeout)
    }

    static var unreadable: FetchFailure {
        FetchFailure(.screenUnreadable, canRetry: false)
    }

    static var unauthorized: FetchFailure {
        FetchFailure(.screenUnauthorized, canRetry: false, endsSession: true)
    }

    static func unexpected(canRetry: Bool) -> FetchFailure {
        FetchFailure(.screenUnexpected, canRetry: canRetry)
    }

    static func server(statusCode: Int, canRetry: Bool) -> FetchFailure {
        FetchFailure(.screenServerError(statusCode), canRetry: canRetry)
    }
}
