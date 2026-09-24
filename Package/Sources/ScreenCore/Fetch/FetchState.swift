import Foundation
import Observation

@MainActor
@Observable
public final class FetchState<Value> {
    public private(set) var phase: FetchPhase<Value> = .idle
    private(set) var running: FetchOperation?

    @ObservationIgnored private var task: Task<Void, Never>?
    @ObservationIgnored private var reachedEnd = false

    public init() {}

    func isRunning(_ operation: FetchOperation) -> Bool {
        running == operation
    }

    @discardableResult
    func reload(_ work: @escaping @MainActor () async throws(FetchFailure) -> Value) -> Task<Void, Never>? {
        reachedEnd = false
        phase = .loading

        return replace(work)
    }

    func refresh(_ work: @escaping @MainActor () async throws(FetchFailure) -> Value) async {
        guard isLoaded else {
            await reload(work)?.value
            return
        }

        reachedEnd = false

        await replace(work)?.value
    }

    @discardableResult
    func loadMore(_ work: @escaping @MainActor () async throws(FetchFailure) -> FetchMore<Value>?)
        -> Task<Void, Never>? {
        guard isLoaded, !reachedEnd else {
            return nil
        }

        return run(.loadMore, replacing: false, work) { result in
            switch result {
            case let .more(value)?:
                self.phase = .loaded(value)

            case let .last(value)?:
                self.reachedEnd = true
                self.phase = .loaded(value)

            case nil:
                break
            }
        }
    }

    @discardableResult
    func update(_ work: @escaping @MainActor () async throws(FetchFailure) -> Value?) -> Task<Void, Never>? {
        guard isLoaded else {
            return nil
        }

        return run(.update, replacing: false, work) { value in
            if let value {
                self.phase = .loaded(value)
            }
        }
    }

    private var isLoaded: Bool {
        if case .loaded = phase {
            true
        } else {
            false
        }
    }

    private func replace(_ work: @escaping @MainActor () async throws(FetchFailure) -> Value) -> Task<Void, Never>? {
        run(.reload, replacing: true, work) { value in
            self.phase = .loaded(value)
        } failed: { failure in
            self.phase = .failed(failure)
        }
    }

    private func run<Output>(
        _ operation: FetchOperation,
        replacing: Bool,
        _ work: @escaping @MainActor () async throws(FetchFailure) -> Output,
        succeeded: @escaping @MainActor (Output) -> Void,
        failed: @escaping @MainActor (FetchFailure) -> Void = { _ in }
    ) -> Task<Void, Never>? {
        if replacing {
            task?.cancel()
        } else if running != nil {
            return nil
        }

        running = operation

        let task = Task {
            let outcome: Result<Output, FetchFailure>

            do throws(FetchFailure) {
                outcome = try await .success(work())
            } catch {
                outcome = .failure(error)
            }

            guard !Task.isCancelled else {
                return
            }

            running = nil

            switch outcome {
            case let .success(value):
                succeeded(value)

            case let .failure(failure):
                failed(failure)
            }
        }

        self.task = task

        return task
    }
}
