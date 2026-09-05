import SwiftUI

public struct ScreenReloadAction {
    private let action: @MainActor @Sendable () -> Void

    public init(_ action: @escaping @MainActor @Sendable () -> Void = {}) {
        self.action = action
    }

    @MainActor
    public func callAsFunction() {
        action()
    }
}

public extension EnvironmentValues {
    @Entry var screenReload = ScreenReloadAction()
}
