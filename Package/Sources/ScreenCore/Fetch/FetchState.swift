import Foundation
import Observation

@MainActor
@Observable
public final class FetchState<Value> {
    public private(set) var phase: FetchPhase<Value> = .idle

    public private(set) var isRefilling = false

    private var reload = FetchRequest()
    private var loadMore = FetchRequest()
    private var refill = FetchRequest()

    @ObservationIgnored private var activeRequest: UUID?
    @ObservationIgnored private var reachedEnd = false

    var reloadID: UUID {
        reload.id
    }

    var loadMoreID: UUID {
        loadMore.id
    }

    var refillID: UUID {
        refill.id
    }

    public init() {}

    func requestReload() {
        activeRequest = nil
        reload.renew()
    }

    func requestLoadMore() {
        guard
            case .loaded = phase,
            !reachedEnd
        else {
            return
        }

        loadMore.renew()
    }

    func requestRefill() {
        guard
            case .loaded = phase,
            !isRefilling
        else {
            return
        }

        refill.renew()
    }

    func run(_ operation: @MainActor () async throws(FetchFailure) -> Value) async {
        guard
            !Task.isCancelled,
            reload.claim()
        else {
            return
        }

        reachedEnd = false
        phase = .loading

        await settle(operation) { value in
            phase = .loaded(value)
        } failed: { failure in
            phase = .failed(failure)
        }

        if case .loading = phase {
            reload.release()
        }
    }

    func runMore(_ operation: @MainActor () async throws(FetchFailure) -> FetchMore<Value>?) async {
        guard loadMore.claim() else {
            return
        }

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

        if case .loadingMore = phase {
            loadMore.release()
            phase = .loaded(current)
        }
    }

    func runRefresh(_ operation: @MainActor () async throws(FetchFailure) -> Value) async {
        guard case .loaded = phase else {
            reload.release()
            await run(operation)
            return
        }

        guard !Task.isCancelled else {
            return
        }

        reachedEnd = false

        await settle(operation) { value in
            phase = .loaded(value)
        } failed: { failure in
            phase = .failed(failure)
        }
    }

    func runRefill(_ operation: @MainActor () async throws(FetchFailure) -> Value?) async {
        guard refill.claim() else {
            return
        }

        guard
            case let .loaded(current) = phase,
            !Task.isCancelled
        else {
            return
        }

        isRefilling = true

        await settle(operation) { value in
            phase = .loaded(value ?? current)
        } failed: { _ in
            phase = .loaded(current)
        }

        isRefilling = false
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
