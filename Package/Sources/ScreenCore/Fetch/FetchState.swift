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

    func run(_ operation: @MainActor () async throws(FetchFailure) -> Value) async {
        guard !Task.isCancelled else {
            return
        }

        reachedEnd = false
        phase = .loading

        await settle(operation) { value in
            phase = .loaded(value)
        } failed: { failure in
            phase = .failed(failure)
        }
    }

    func runMore(_ operation: @MainActor () async throws(FetchFailure) -> FetchMore<Value>?) async {
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
        _ operation: @MainActor () async throws(FetchFailure) -> Result,
        succeeded: @MainActor (Result) -> Void,
        failed: @MainActor (FetchFailure) -> Void
    ) async {
        let request = UUID()
        activeRequest = request

        do {
            let value = try await operation()

            guard
                !Task.isCancelled,
                activeRequest == request
            else {
                return
            }

            succeeded(value)
        } catch {
            guard
                !Task.isCancelled,
                activeRequest == request
            else {
                return
            }

            failed(error)
        }
    }
}
