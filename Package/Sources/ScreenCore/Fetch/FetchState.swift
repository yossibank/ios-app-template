import Foundation
import Observation

@MainActor
@Observable
public final class FetchState<Value> {
    public private(set) var phase: FetchPhase<Value> = .idle

    private var requests: [FetchOperation: FetchRequest]
    private var running: Set<FetchOperation> = []

    @ObservationIgnored private var activeRequest: UUID?
    @ObservationIgnored private var reachedEnd = false
    @ObservationIgnored private let unstarted = UUID()

    public init() {
        self.requests = Dictionary(
            uniqueKeysWithValues: FetchOperation.allCases.map { ($0, FetchRequest()) }
        )
    }

    func id(of operation: FetchOperation) -> UUID {
        requests[operation]?.id ?? unstarted
    }

    func isRunning(_ operation: FetchOperation) -> Bool {
        running.contains(operation)
    }

    func request(_ operation: FetchOperation) {
        guard accepts(operation) else {
            return
        }

        if operation == .reload {
            activeRequest = nil
        }

        requests[operation]?.renew()
    }

    func runReload(_ work: @MainActor () async throws(FetchFailure) -> Value) async {
        guard
            !Task.isCancelled,
            claim(.reload)
        else {
            return
        }

        reachedEnd = false
        phase = .loading

        await settle(.reload, work) { value in
            phase = .loaded(value)
        } failed: { failure in
            phase = .failed(failure)
        }
    }

    func runMore(_ work: @MainActor () async throws(FetchFailure) -> FetchMore<Value>?) async {
        guard claim(.loadMore) else {
            return
        }

        guard
            case let .loaded(current) = phase,
            !Task.isCancelled
        else {
            release(.loadMore)
            return
        }

        await settle(.loadMore, work) { result in
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

    func runRefill(_ work: @MainActor () async throws(FetchFailure) -> Value?) async {
        guard claim(.refill) else {
            return
        }

        guard
            case let .loaded(current) = phase,
            !Task.isCancelled
        else {
            release(.refill)
            return
        }

        await settle(.refill, work) { value in
            phase = .loaded(value ?? current)
        } failed: { _ in
            phase = .loaded(current)
        }
    }

    func runRefresh(_ work: @MainActor () async throws(FetchFailure) -> Value) async {
        guard case .loaded = phase else {
            release(.reload)
            await runReload(work)
            return
        }

        guard !Task.isCancelled else {
            return
        }

        reachedEnd = false

        await settle(.reload, work) { value in
            phase = .loaded(value)
        } failed: { failure in
            phase = .failed(failure)
        }
    }

    private func accepts(_ operation: FetchOperation) -> Bool {
        switch operation {
        case .reload:
            return true

        case .loadMore:
            guard case .loaded = phase else {
                return false
            }

            return !reachedEnd && !isRunning(.loadMore)

        case .refill:
            guard case .loaded = phase else {
                return false
            }

            return !isRunning(.refill)
        }
    }

    private func claim(_ operation: FetchOperation) -> Bool {
        requests[operation]?.claim() ?? false
    }

    private func release(_ operation: FetchOperation) {
        requests[operation]?.release()
    }

    private func settle<Result>(
        _ operation: FetchOperation,
        _ work: @MainActor () async throws(FetchFailure) -> Result,
        succeeded: @MainActor (Result) -> Void,
        failed: @MainActor (FetchFailure) -> Void
    ) async {
        let request = UUID()

        activeRequest = request
        running.insert(operation)

        defer {
            running.remove(operation)
        }

        do {
            let value = try await work()

            guard
                !Task.isCancelled,
                activeRequest == request
            else {
                release(operation)
                return
            }

            succeeded(value)
        } catch {
            guard
                !Task.isCancelled,
                activeRequest == request
            else {
                release(operation)
                return
            }

            failed(error)
        }
    }
}
