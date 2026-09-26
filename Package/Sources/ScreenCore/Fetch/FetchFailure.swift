import Foundation

public struct FetchFailure: LocalizedError, Hashable, Sendable {
    public let message: String
    public let canRetry: Bool

    public var errorDescription: String? {
        message
    }

    public init(_ message: String, canRetry: Bool = true) {
        self.message = message
        self.canRetry = canRetry
    }

    public init(_ message: LocalizedStringResource, canRetry: Bool = true) {
        self.init(String(localized: message), canRetry: canRetry)
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

    static func unexpected(canRetry: Bool) -> FetchFailure {
        FetchFailure(.screenUnexpected, canRetry: canRetry)
    }

    static func server(statusCode: Int, canRetry: Bool) -> FetchFailure {
        FetchFailure(.screenServerError(statusCode), canRetry: canRetry)
    }
}
