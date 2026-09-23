@testable import ScreenCore
import Testing

@MainActor
struct FetchStateTests {
    @Test("取得に成功したら一覧になる")
    func loads() async {
        let state = FetchState<[Int]>()

        await state.run { [1, 2] }

        #expect(state.phase.loaded == [1, 2])
    }

    @Test("画面に戻っただけでは取得し直さない")
    func reappearingDoesNotRefetch() async {
        let state = FetchState<[Int]>()
        var calls = 0

        await state.run {
            calls += 1
            return [1]
        }

        await state.run {
            calls += 1
            return [2]
        }

        #expect(calls == 1, "画面に戻るたびに取得し直している")
        #expect(state.phase.loaded == [1])
    }

    @Test("再取得を頼めば走り直す")
    func reloadRunsAgain() async {
        let state = FetchState<[Int]>()
        var calls = 0

        await state.run {
            calls += 1
            return [1]
        }

        state.requestReload()

        await state.run {
            calls += 1
            return [2]
        }

        #expect(calls == 2, "再取得を頼んだのに走っていない")
        #expect(state.phase.loaded == [2])
    }

    @Test("画面に戻っただけでは続きを読まない")
    func reappearingDoesNotLoadMore() async {
        let state = FetchState<[Int]>()
        var calls = 0

        await state.run { [1] }
        state.requestLoadMore()

        await state.runMore {
            calls += 1
            return .more([1, 2])
        }

        await state.runMore {
            calls += 1
            return .more([1, 2, 3])
        }

        #expect(calls == 1, "画面に戻るたびに次のページを読んでいる")
        #expect(state.phase.loaded == [1, 2])
    }

    @Test("プルして再取得している間も一覧は消えない")
    func refreshKeepsTheListOnScreen() async {
        let state = FetchState<[Int]>()
        let gate = Gate()

        await state.run { [1] }

        let running = Task { await state.runRefresh { await gate.wait(); return [2] } }
        await gate.waitUntilEntered()

        #expect(state.phase.loaded == [1], "再取得の途中で一覧が消えている")

        gate.open()
        await running.value

        #expect(state.phase.loaded == [2])
    }

    @Test("何も出ていないときの再取得は通常の取得として扱う")
    func refreshWithNothingOnScreenLoads() async {
        let state = FetchState<[Int]>()

        await state.runRefresh { [1] }

        #expect(state.phase.loaded == [1])
    }

    @Test("再取得を頼むと、進行中の取得結果は捨てられる")
    func reloadDiscardsInFlightResult() async {
        let state = FetchState<[Int]>()
        let gate = Gate()

        let running = Task { await state.run { await gate.wait(); return [1] } }
        await gate.waitUntilEntered()

        state.requestReload()
        gate.open()
        await running.value

        #expect(state.phase.loaded == nil)
    }

    @Test("取り消された後に返ってきた結果は出さない")
    func cancelledResultIsDropped() async {
        let state = FetchState<[Int]>()
        let gate = Gate()

        let running = Task { await state.run { await gate.wait(); return [1] } }
        await gate.waitUntilEntered()

        running.cancel()
        gate.open()
        await running.value

        #expect(state.phase.loaded == nil)
    }

    @Test("取り消された後に失敗が返っても、失敗として出さない")
    func cancelledFailureIsDropped() async {
        let state = FetchState<[Int]>()
        let gate = Gate()

        let running = Task {
            await state.run { () async throws(FetchFailure) -> [Int] in
                await gate.wait()
                throw FetchFailure("取り消した後の失敗")
            }
        }
        await gate.waitUntilEntered()

        running.cancel()
        gate.open()
        await running.value

        #expect(state.phase.failure == nil)
    }

    @Test("取得が失敗したら失敗状態になる")
    func failureBecomesFailed() async {
        let state = FetchState<[Int]>()

        await state.run { () async throws(FetchFailure) -> [Int] in
            throw FetchFailure("取得に失敗しました")
        }

        #expect(state.phase.failure?.message == "取得に失敗しました")
    }

    @Test("続きの取得が失敗しても、読み込めている分は消えない")
    func loadMoreFailureKeepsWhatWasLoaded() async {
        let state = FetchState<[Int]>()
        await state.run { [1, 2] }

        await state.runMore { () async throws(FetchFailure) -> FetchMore<[Int]>? in
            throw FetchFailure("取得に失敗しました")
        }

        #expect(state.phase.loaded == [1, 2])
        #expect(state.phase.isLoadingMore == false)
    }

    @Test("続きが無いと返ったら一覧はそのまま")
    func loadMoreNilKeepsList() async {
        let state = FetchState<[Int]>()
        await state.run { [1, 2] }

        await state.runMore { nil }

        #expect(state.phase.loaded == [1, 2])
        #expect(state.phase.isLoadingMore == false)
    }

    @Test("続きの取得中に再取得しても、読み込み中の表示が残らない")
    func reloadDuringLoadMoreClearsLoadingMore() async {
        let state = FetchState<[Int]>()
        await state.run { [1] }

        let gate = Gate()
        let more = Task { await state.runMore { await gate.wait(); return .more([1, 2]) } }
        await gate.waitUntilEntered()

        state.requestReload()
        await state.run { [9] }

        gate.open()
        await more.value

        #expect(state.phase.loaded == [9])
        #expect(state.phase.isLoadingMore == false)

        let before = state.loadMoreID
        state.requestLoadMore()
        #expect(state.loadMoreID != before, "続きを読めなくなっている")
    }

    @Test("終端を受け取ったら、もう続きを要求しない")
    func stopsAskingAfterTheLastPage() async {
        let state = FetchState<[Int]>()
        await state.run { [1] }

        await state.runMore { .last([1, 2]) }

        let before = state.loadMoreID
        state.requestLoadMore()

        #expect(state.loadMoreID == before)
        #expect(state.phase.loaded == [1, 2])
    }

    @Test("再取得すると終端の記憶は消える")
    func reloadForgetsTheEnd() async {
        let state = FetchState<[Int]>()
        await state.run { [1] }
        await state.runMore { .last([1, 2]) }

        state.requestReload()
        await state.run { [1] }

        let before = state.loadMoreID
        state.requestLoadMore()

        #expect(state.loadMoreID != before)
    }

    @Test("読み込めていないうちは続きを取りにいかない")
    func loadMoreDoesNothingBeforeLoaded() async {
        let state = FetchState<[Int]>()
        var asked = false

        await state.runMore {
            asked = true
            return .more([9])
        }

        #expect(asked == false)
        #expect(state.phase.loaded == nil)
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
