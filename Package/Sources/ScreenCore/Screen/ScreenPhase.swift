import Foundation

public enum ScreenPhase<Value> {
    case idle
    case loading
    case loaded(Value)
    case failed(any Error)
}

public struct ScreenFailure: LocalizedError, Sendable {
    public let message: String

    public init(_ message: String) {
        self.message = message
    }

    public var errorDescription: String? {
        message
    }
}
