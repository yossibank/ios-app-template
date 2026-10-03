import Foundation
import Observation

@MainActor
@Observable
public final class FetchState<Value> {
    public private(set) var phase: FetchPhase<Value> = .idle
    public private(set) var sessionEnded = false

    private(set) var running: FetchOperation?

    @ObservationIgnored private var task: Task<Void, Never>?
    @ObservationIgnored private var reachedEnd = false

    private var isLoaded: Bool {
        if case .loaded = phase {
            true
        } else {
            false
        }
    }

    public init() {}

    func isRunning(_ operation: FetchOperation) -> Bool {
        running == operation
    }

    @discardableResult
    func reload(
        _ work: @escaping @MainActor () async throws(FetchFailure) -> Value
    ) -> Task<Void, Never>? {
        reachedEnd = false
        phase = .loading

        return run(.reload, work, then: show)
    }

    @discardableResult
    func refresh(
        _ work: @escaping @MainActor () async throws(FetchFailure) -> Value
    ) -> Task<Void, Never>? {
        guard isLoaded else {
            return reload(work)
        }

        reachedEnd = false

        return run(.refresh, work, then: show)
    }

    @discardableResult
    func loadMore(
        _ work: @escaping @MainActor (Value) async throws(FetchFailure) -> FetchMore<Value>
    ) -> Task<Void, Never>? {
        guard
            case let .loaded(current) = phase,
            !reachedEnd,
            running == nil
        else {
            return nil
        }

        return run(.loadMore) { () async throws(FetchFailure) in
            try await work(current)
        } then: { result in
            switch result {
            case let .success(.more(value)):
                self.phase = .loaded(value)

            case let .success(.last(value)):
                self.reachedEnd = true
                self.phase = .loaded(value)

            case .success(.unchanged), .failure:
                break
            }
        }
    }

    private func show(_ result: Result<Value, FetchFailure>) {
        switch result {
        case let .success(value):
            phase = .loaded(value)

        case let .failure(failure):
            phase = .failed(failure)
        }
    }

    private func run<Output>(
        _ operation: FetchOperation,
        _ work: @escaping @MainActor () async throws(FetchFailure) -> Output,
        then apply: @escaping @MainActor (Result<Output, FetchFailure>) -> Void
    ) -> Task<Void, Never> {
        task?.cancel()
        running = operation

        let task = Task {
            let result: Result<Output, FetchFailure>

            do throws(FetchFailure) {
                result = try await .success(work())
            } catch {
                if error.endsSession {
                    sessionEnded = true
                }

                result = .failure(error)
            }

            guard !Task.isCancelled else {
                return
            }

            running = nil
            apply(result)
        }

        self.task = task

        return task
    }
}
