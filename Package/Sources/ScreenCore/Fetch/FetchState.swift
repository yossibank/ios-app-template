import Foundation
import Observation

@MainActor
@Observable
public final class FetchState<Value> {
    public private(set) var phase: FetchPhase<Value> = .idle
    public private(set) var isLoadingMore = false

    private(set) var reloadID = UUID()
    private(set) var loadMoreID = UUID()

    @ObservationIgnored private var activeRequest: UUID?

    public init() {}

    func requestReload() {
        activeRequest = nil
        reloadID = UUID()
    }

    func requestLoadMore() {
        guard case .loaded = phase, !isLoadingMore else {
            return
        }

        loadMoreID = UUID()
    }

    func run(_ operation: @MainActor () async throws -> Value) async {
        guard !Task.isCancelled else {
            return
        }

        let request = UUID()
        activeRequest = request
        phase = .loading

        do {
            let value = try await operation()

            try Task.checkCancellation()

            guard activeRequest == request else {
                return
            }

            phase = .loaded(value)
        } catch {
            guard
                activeRequest == request,
                !Task.isCancelled,
                !(error is CancellationError)
            else {
                return
            }

            phase = .failed(error)
        }
    }

    func runMore(_ operation: @MainActor () async throws -> Value?) async {
        guard case .loaded = phase, !Task.isCancelled, !isLoadingMore else {
            return
        }

        let request = UUID()
        activeRequest = request
        isLoadingMore = true

        do {
            let value = try await operation()

            try Task.checkCancellation()

            guard activeRequest == request else {
                return
            }

            isLoadingMore = false

            if let value {
                phase = .loaded(value)
            }
        } catch {
            guard activeRequest == request, !Task.isCancelled, !(error is CancellationError) else {
                return
            }

            isLoadingMore = false
        }
    }
}
