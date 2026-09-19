import SwiftUI

public struct ScreenAction: Equatable, Sendable {
    enum Kind {
        case reload
        case loadMore
    }

    private let kind: Kind
    private let screenID: UUID?
    private let perform: @MainActor @Sendable () -> Void

    init(_ kind: Kind) {
        self.kind = kind
        self.screenID = nil
        self.perform = {}
    }

    init(
        _ kind: Kind,
        screenID: UUID,
        _ perform: @MainActor @Sendable @escaping () -> Void
    ) {
        self.kind = kind
        self.screenID = screenID
        self.perform = perform
    }

    @MainActor
    public func callAsFunction() {
        perform()
    }

    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.kind == rhs.kind && lhs.screenID == rhs.screenID
    }
}

public extension EnvironmentValues {
    @Entry var screenReload = ScreenAction(.reload)
    @Entry var screenLoadMore = ScreenAction(.loadMore)
    @Entry var screenIsLoadingMore = false
}
