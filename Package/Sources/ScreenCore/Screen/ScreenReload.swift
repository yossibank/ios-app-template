import SwiftUI

public extension EnvironmentValues {
    @Entry var screenReload: @MainActor @Sendable () -> Void = {}
}
