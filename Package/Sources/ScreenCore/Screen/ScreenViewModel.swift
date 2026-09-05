import Foundation

@MainActor
public protocol ScreenViewModel: ViewModel {
    associatedtype Value

    var screen: ScreenState<Value> { get }

    func fetch() async throws -> Value
}

extension ScreenViewModel {
    public var phase: ScreenPhase<Value> {
        screen.phase
    }

    func load() async {
        await screen.run {
            try await fetch()
        }
    }

    func reload() {
        screen.requestReload()
    }
}
