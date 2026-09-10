import Foundation

public struct FetchFailure: LocalizedError, Sendable {
    public let message: String
    public let canRetry: Bool

    public init(_ message: String, canRetry: Bool = true) {
        self.message = message
        self.canRetry = canRetry
    }

    public var errorDescription: String? {
        message
    }
}
