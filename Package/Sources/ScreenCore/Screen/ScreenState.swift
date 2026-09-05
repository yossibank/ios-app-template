import Foundation
import Observation

@MainActor
@Observable
public final class ScreenState<Value> {
    public private(set) var phase: ScreenPhase<Value> = .idle

    private(set) var reloadID = UUID()

    @ObservationIgnored private var activeRequest: UUID?

    public init() {}

    func requestReload() {
        activeRequest = nil
        reloadID = UUID()
    }

    func run(_ operation: @MainActor () async throws -> Value) async {
        guard !Task.isCancelled else {
            return
        }

        let request = UUID()
        activeRequest = request
        phase = .loading

        defer {
            if activeRequest == request {
                activeRequest = nil
            }
        }

        do {
            let value = try await operation()

            try Task.checkCancellation()

            guard activeRequest == request else {
                return
            }

            phase = .loaded(value)
        } catch {
            guard activeRequest == request else {
                return
            }

            guard
                !Task.isCancelled,
                !(error is CancellationError)
            else {
                return
            }

            phase = .failed(error)
        }
    }
}
