import Foundation
import Observation

@MainActor
@Observable
public final class FetchState<Value> {
    public private(set) var phase: FetchPhase<Value> = .idle

    private(set) var reloadID = UUID()
    private(set) var loadMoreID = UUID()

    @ObservationIgnored private var activeRequest: UUID?
    @ObservationIgnored private var reachedEnd = false

    public init() {}

    func requestReload() {
        activeRequest = nil
        reloadID = UUID()
    }

    func requestLoadMore() {
        guard
            case .loaded = phase,
            !reachedEnd
        else {
            return
        }

        loadMoreID = UUID()
    }

    func run(_ operation: @MainActor () async throws -> Value) async {
        guard !Task.isCancelled else {
            return
        }

        reachedEnd = false
        phase = .loading

        await settle(operation) { value in
            phase = .loaded(value)
        } failed: { error in
            phase = .failed(error)
        }
    }

    func runMore(_ operation: @MainActor () async throws -> FetchMore<Value>?) async {
        guard
            case let .loaded(current) = phase,
            !Task.isCancelled
        else {
            return
        }

        phase = .loadingMore(current)

        await settle(operation) { result in
            switch result {
            case let .more(value)?:
                phase = .loaded(value)

            case let .last(value)?:
                reachedEnd = true
                phase = .loaded(value)

            case nil:
                reachedEnd = true
                phase = .loaded(current)
            }
        } failed: { _ in
            phase = .loaded(current)
        }
    }

    private func settle<Result>(
        _ operation: @MainActor () async throws -> Result,
        succeeded: @MainActor (Result) -> Void,
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
