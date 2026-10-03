import ScreenCore
import Shared

public enum LoginOutcome: Hashable, Sendable {
    case loggedIn
    case rejected
    case failed(FetchFailure)
}

public protocol Authenticating: Sendable {
    func login(username: String, password: String) async -> LoginOutcome
}

public struct SessionAuthenticator: Authenticating {
    public init() {}

    public func login(username: String, password: String) async -> LoginOutcome {
        do {
            return try await LoginOutcome(Session.shared.login(
                username: username,
                password: password
            ))
        } catch {
            return .failed(.unexpected(canRetry: true))
        }
    }
}

extension LoginOutcome {
    init(_ result: any LoginResult) {
        self = switch onEnum(of: result) {
        case .loggedIn:
            .loggedIn

        case .rejected:
            .rejected

        case let .failed(failed):
            .failed(FetchFailure(failed.failure))
        }
    }
}
