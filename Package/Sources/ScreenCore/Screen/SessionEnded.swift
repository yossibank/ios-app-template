import SwiftUI

public struct SessionEndedAction: Sendable {
    private let action: @MainActor @Sendable () -> Void

    public init(_ action: @escaping @MainActor @Sendable () -> Void) {
        self.action = action
    }

    @MainActor
    public func callAsFunction() {
        action()
    }
}

public extension EnvironmentValues {
    @Entry var onSessionEnded = SessionEndedAction {}
}

public extension View {
    func onSessionEnded(_ action: @escaping @MainActor @Sendable () -> Void) -> some View {
        environment(\.onSessionEnded, SessionEndedAction(action))
    }
}
