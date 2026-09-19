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

        phase = .loading

        await settle(operation) { value in
            if let value {
                phase = .loaded(value)
            }
        } failed: { error in
            phase = .failed(error)
        }
    }

    func runMore(_ operation: @MainActor () async throws -> Value?) async {
        guard case .loaded = phase, !Task.isCancelled, !isLoadingMore else {
            return
        }

        isLoadingMore = true

        await settle(operation) { value in
            isLoadingMore = false

            if let value {
                phase = .loaded(value)
            }
        } failed: { _ in
            isLoadingMore = false
        }
    }

    private func settle(
        _ operation: @MainActor () async throws -> Value?,
        succeeded: @MainActor (Value?) -> Void,
        failed: @MainActor (any Error) -> Void
    ) async {
        let request = UUID()
        activeRequest = request

        do {
            let value = try await operation()

            try Task.checkCancellation()

            guard activeRequest == request else {
                return
            }

            succeeded(value)
        } catch {
            guard
                activeRequest == request,
                !Task.isCancelled,
                !(error is CancellationError)
            else {
                return
            }

            failed(error)
        }
    }
}
