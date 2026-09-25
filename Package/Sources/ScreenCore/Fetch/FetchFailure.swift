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
}

public extension FetchFailure {
    static var offline: FetchFailure {
        FetchFailure(ScreenStrings.offline)
    }

    static var timeout: FetchFailure {
        FetchFailure(ScreenStrings.timeout)
    }

    static var unreadable: FetchFailure {
        FetchFailure(ScreenStrings.unreadable, canRetry: false)
    }

    static func unexpected(canRetry: Bool) -> FetchFailure {
        FetchFailure(ScreenStrings.unexpected, canRetry: canRetry)
    }

    static func server(statusCode: Int, canRetry: Bool) -> FetchFailure {
        FetchFailure(ScreenStrings.serverError(statusCode: statusCode), canRetry: canRetry)
    }
}
