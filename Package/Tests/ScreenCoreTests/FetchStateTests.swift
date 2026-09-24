import Observation
@testable import ScreenCore
import Testing

@MainActor
struct FetchStateTests {
    @Test("取得に成功したら一覧になる")
    func loads() async {
        let state = FetchState<[Int]>()

        await state.reload { [1, 2] }?.value

        #expect(state.phase.loaded == [1, 2])
    }

    @Test("画面に戻っただけでは取得し直さない")
    func reappearingDoesNotRefetch() async {
        let model = CountingModel()

        model.start()
        await model.settle()
        model.start()
        await model.settle()

        #expect(model.fetchCalls == 1, "画面に戻るたびに取得し直している")
    }

    @Test("再取得を頼めば走り直す")
    func reloadRunsAgain() async {
        let state = FetchState<[Int]>()
        var calls = 0

        await state.reload {
            calls += 1
            return [1]
        }?.value

        await state.reload {
            calls += 1
            return [2]
        }?.value

        #expect(calls == 2, "再取得を頼んだのに走っていない")
        #expect(state.phase.loaded == [2])
    }

    @Test("プルして再取得している間も一覧は消えない")
    func refreshKeepsTheListOnScreen() async {
        let state = FetchState<[Int]>()
        let gate = Gate()

        await state.reload { [1] }?.value

        let running = state.refresh { await gate.wait(); return [2] }
        await gate.waitUntilEntered()

        #expect(state.phase.loaded == [1], "再取得の途中で一覧が消えている")
        #expect(state.isRunning(.refresh))

        gate.open()
        await running?.value

        #expect(state.phase.loaded == [2])
    }

    @Test("何も出ていないときの再取得は通常の取得として扱う")
    func refreshWithNothingOnScreenLoads() async {
        let state = FetchState<[Int]>()

        await state.refresh { [1] }?.value

        #expect(state.phase.loaded == [1])
    }

    @Test("再取得を頼むと、進行中の取得結果は捨てられる")
    func reloadDiscardsInFlightResult() async {
        let state = FetchState<[Int]>()
        let gate = Gate()

        let first = state.reload { await gate.wait(); return [1] }
        await gate.waitUntilEntered()

        await state.reload { [2] }?.value
        gate.open()
        await first?.value

        #expect(state.phase.loaded == [2], "置き換えられた取得の結果が上書きしている")
    }

    @Test("置き換えられた後に失敗が返っても、失敗として出さない")
    func replacedFailureIsDropped() async {
        let state = FetchState<[Int]>()
        let gate = Gate()

        let first = state.reload { () async throws(FetchFailure) -> [Int] in
            await gate.wait()
            throw FetchFailure("置き換えた後の失敗")
        }
        await gate.waitUntilEntered()

        await state.reload { [2] }?.value
        gate.open()
        await first?.value

        #expect(state.phase.failure == nil)
        #expect(state.phase.loaded == [2])
    }

    @Test("取得が失敗したら失敗状態になる")
    func failureBecomesFailed() async {
        let state = FetchState<[Int]>()

        await state.reload { () async throws(FetchFailure) -> [Int] in
            throw FetchFailure("取得に失敗しました")
        }?.value

        #expect(state.phase.failure?.message == "取得に失敗しました")
    }

    @Test("続きの取得が失敗しても、読み込めている分は消えない")
    func loadMoreFailureKeepsWhatWasLoaded() async {
        let state = FetchState<[Int]>()
        await state.reload { [1, 2] }?.value

        await state.loadMore { () async throws(FetchFailure) -> FetchMore<[Int]>? in
            throw FetchFailure("取得に失敗しました")
        }?.value

        #expect(state.phase.loaded == [1, 2])
        #expect(state.isRunning(.loadMore) == false)
    }

    @Test("続きが返らなかったら一覧はそのままで、続きを頼み直せる")
    func loadMoreNilKeepsListAndCanBeRetried() async {
        let state = FetchState<[Int]>()
        await state.reload { [1, 2] }?.value

        await state.loadMore { nil }?.value

        #expect(state.phase.loaded == [1, 2])
        #expect(state.isRunning(.loadMore) == false)

        await state.loadMore { .more([1, 2, 3]) }?.value

        #expect(state.phase.loaded == [1, 2, 3], "続きが返らなかった後に続きを頼み直せない")
    }

    @Test("続きの取得中に再取得すると、続きの結果は捨てられ、読み込み中の表示も残らない")
    func reloadDuringLoadMoreDiscardsIt() async {
        let state = FetchState<[Int]>()
        await state.reload { [1] }?.value

        let gate = Gate()
        let more = state.loadMore { await gate.wait(); return .more([1, 2]) }
        await gate.waitUntilEntered()

        await state.reload { [9] }?.value

        gate.open()
        await more?.value

        #expect(state.phase.loaded == [9])
        #expect(state.isRunning(.loadMore) == false)

        await state.loadMore { .more([9, 10]) }?.value
        #expect(state.phase.loaded == [9, 10], "続きを読めなくなっている")
    }

    @Test("終端を受け取ったら、もう続きを取りにいかない")
    func stopsAskingAfterTheLastPage() async {
        let state = FetchState<[Int]>()
        await state.reload { [1] }?.value

        await state.loadMore { .last([1, 2]) }?.value

        var asked = false
        await state.loadMore {
            asked = true
            return .more([1, 2, 3])
        }?.value

        #expect(asked == false)
        #expect(state.phase.loaded == [1, 2])
    }

    @Test("再取得すると終端の記憶は消える")
    func reloadForgetsTheEnd() async {
        let state = FetchState<[Int]>()
        await state.reload { [1] }?.value
        await state.loadMore { .last([1, 2]) }?.value

        await state.reload { [1] }?.value
        await state.loadMore { .more([1, 3]) }?.value

        #expect(state.phase.loaded == [1, 3])
    }

    @Test("読み込めていないうちは続きを取りにいかない")
    func loadMoreDoesNothingBeforeLoaded() async {
        let state = FetchState<[Int]>()
        var asked = false

        await state.loadMore {
            asked = true
            return .more([9])
        }?.value

        #expect(asked == false)
        #expect(state.phase.loaded == nil)
    }

    @Test("プルして再取得している間は続きを取りにいかない")
    func loadMoreWaitsForRefresh() async {
        let state = FetchState<[Int]>()
        await state.reload { [1] }?.value

        let gate = Gate()
        let refreshing = state.refresh { await gate.wait(); return [2] }
        await gate.waitUntilEntered()

        var asked = false
        let more = state.loadMore {
            asked = true
            return .more([2, 3])
        }

        gate.open()
        await refreshing?.value

        #expect(more == nil)
        #expect(asked == false, "再取得と続きの取得が重なっている")
        #expect(state.phase.loaded == [2])
    }
}

@MainActor
@Observable
private final class CountingModel: ScreenViewModel {
    let fetchState = FetchState<[Int]>()
    private(set) var fetchCalls = 0

    func fetch() async throws(FetchFailure) -> [Int] {
        fetchCalls += 1
        return [fetchCalls]
    }

    func settle() async {
        while fetchState.isRunning(.reload) {
            await Task.yield()
        }
    }
}

@MainActor
private final class Gate {
    private var continuation: CheckedContinuation<Void, Never>?
    private var entered = false

    func wait() async {
        await withCheckedContinuation { continuation in
            self.continuation = continuation
            entered = true
        }
    }

    func waitUntilEntered() async {
        while !entered {
            await Task.yield()
        }
    }

    func open() {
        continuation?.resume()
        continuation = nil
    }
}

private extension FetchPhase {
    var loaded: Value? {
        guard case let .loaded(value) = self else {
            return nil
        }

        return value
    }

    var failure: FetchFailure? {
        guard case let .failed(failure) = self else {
            return nil
        }

        return failure
    }
}
