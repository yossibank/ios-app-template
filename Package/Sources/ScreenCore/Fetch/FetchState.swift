import Foundation
import Observation

@MainActor
@Observable
public final class FetchState<Value> {
    public private(set) var phase: FetchPhase<Value> = .idle

    private var ids: [FetchOperation: UUID]
    private var running: Set<FetchOperation> = []

    @ObservationIgnored private var served: [FetchOperation: UUID] = [:]
    @ObservationIgnored private var activeRequests: [FetchOperation: UUID] = [:]
    @ObservationIgnored private var generation = 0
    @ObservationIgnored private var reachedEnd = false
    @ObservationIgnored private let unstarted = UUID()

    public init() {
        self.ids = Dictionary(
            uniqueKeysWithValues: FetchOperation.allCases.map { ($0, UUID()) }
        )
    }

    func id(of operation: FetchOperation) -> UUID {
        ids[operation] ?? unstarted
    }

    func isRunning(_ operation: FetchOperation) -> Bool {
        running.contains(operation)
    }

    func request(_ operation: FetchOperation) {
        guard accepts(operation) else {
            return
        }

        if operation == .reload {
            generation += 1
        }

        ids[operation] = UUID()
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
            case .loaded = phase,
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
            }
        }
    }

    func runRepair(_ work: @MainActor () async throws(FetchFailure) -> Value?) async {
        guard claim(.repair) else {
            return
        }

        guard
            case .loaded = phase,
            !Task.isCancelled
        else {
            release(.repair)
            return
        }

        await settle(.repair, work) { value in
            guard let value else {
                return
            }

            phase = .loaded(value)
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

        generation += 1
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

        case .repair:
            guard case .loaded = phase else {
                return false
            }

            return !isRunning(.repair)
        }
    }

    private func claim(_ operation: FetchOperation) -> Bool {
        guard
            let id = ids[operation],
            served[operation] != id
        else {
            return false
        }

        served[operation] = id

        return true
    }

    private func release(_ operation: FetchOperation) {
        served[operation] = nil
    }

    private func settle<Result>(
        _ operation: FetchOperation,
        _ work: @MainActor () async throws(FetchFailure) -> Result,
        succeeded: @MainActor (Result) -> Void,
        failed: @MainActor (FetchFailure) -> Void = { _ in }
    ) async {
        let request = UUID()
        let startedAt = generation

        activeRequests[operation] = request
        running.insert(operation)

        defer {
            running.remove(operation)
        }

        do {
            let value = try await work()

            guard stillCurrent(operation, request, startedAt) else {
                release(operation)
                return
            }

            succeeded(value)
        } catch {
            guard stillCurrent(operation, request, startedAt) else {
                release(operation)
                return
            }

            failed(error)
        }
    }

    private func stillCurrent(_ operation: FetchOperation, _ request: UUID, _ startedAt: Int) -> Bool {
        !Task.isCancelled
            && generation == startedAt
            && activeRequests[operation] == request
    }
}
