import Observation
@testable import ScreenCore
import Testing

@MainActor
struct FetchStateTests {
    @Test("取得が走っただけでは .task のきっかけを作り直さない")
    func runningDoesNotRenewTheRequestID() async {
        let state = FetchState<[Int]>()
        let renewed = Flag()

        withObservationTracking {
            _ = state.id(of: .reload)
        } onChange: {
            renewed.raise()
        }

        await state.runReload { [1] }

        #expect(renewed.isRaised == false, "取得しただけで .task が作り直されている")
    }

    @Test("再取得を頼んだときは .task のきっかけを作り直す")
    func requestingRenewsTheRequestID() async {
        let state = FetchState<[Int]>()
        await state.runReload { [1] }

        let renewed = Flag()

        withObservationTracking {
            _ = state.id(of: .reload)
        } onChange: {
            renewed.raise()
        }

        state.request(.reload)

        #expect(renewed.isRaised, "再取得を頼んだのに .task が作り直されない")
    }

    @Test("取得に成功したら一覧になる")
    func loads() async {
        let state = FetchState<[Int]>()

        await state.runReload { [1, 2] }

        #expect(state.phase.loaded == [1, 2])
    }

    @Test("画面に戻っただけでは取得し直さない")
    func reappearingDoesNotRefetch() async {
        let state = FetchState<[Int]>()
        var calls = 0

        await state.runReload {
            calls += 1
            return [1]
        }

        await state.runReload {
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

        await state.runReload {
            calls += 1
            return [1]
        }

        state.request(.reload)

        await state.runReload {
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

        await state.runReload { [1] }
        state.request(.loadMore)

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

        await state.runReload { [1] }

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

        let running = Task { await state.runReload { await gate.wait(); return [1] } }
        await gate.waitUntilEntered()

        state.request(.reload)
        gate.open()
        await running.value

        #expect(state.phase.loaded == nil)
    }

    @Test("取り消された後に返ってきた結果は出さない")
    func cancelledResultIsDropped() async {
        let state = FetchState<[Int]>()
        let gate = Gate()

        let running = Task { await state.runReload { await gate.wait(); return [1] } }
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
            await state.runReload { () async throws(FetchFailure) -> [Int] in
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

        await state.runReload { () async throws(FetchFailure) -> [Int] in
            throw FetchFailure("取得に失敗しました")
        }

        #expect(state.phase.failure?.message == "取得に失敗しました")
    }

    @Test("続きの取得が失敗しても、読み込めている分は消えない")
    func loadMoreFailureKeepsWhatWasLoaded() async {
        let state = FetchState<[Int]>()
        await state.runReload { [1, 2] }

        await state.runMore { () async throws(FetchFailure) -> FetchMore<[Int]>? in
            throw FetchFailure("取得に失敗しました")
        }

        #expect(state.phase.loaded == [1, 2])
        #expect(state.isRunning(.loadMore) == false)
    }

    @Test("続きが無いと返ったら一覧はそのまま")
    func loadMoreNilKeepsList() async {
        let state = FetchState<[Int]>()
        await state.runReload { [1, 2] }

        await state.runMore { nil }

        #expect(state.phase.loaded == [1, 2])
        #expect(state.isRunning(.loadMore) == false)
    }

    @Test("続きの取得中に再取得しても、読み込み中の表示が残らない")
    func reloadDuringLoadMoreClearsLoadingMore() async {
        let state = FetchState<[Int]>()
        await state.runReload { [1] }

        let gate = Gate()
        let more = Task { await state.runMore { await gate.wait(); return .more([1, 2]) } }
        await gate.waitUntilEntered()

        state.request(.reload)
        await state.runReload { [9] }

        gate.open()
        await more.value

        #expect(state.phase.loaded == [9])
        #expect(state.isRunning(.loadMore) == false)

        let before = state.id(of: .loadMore)
        state.request(.loadMore)
        #expect(state.id(of: .loadMore) != before, "続きを読めなくなっている")
    }

    @Test("終端を受け取ったら、もう続きを要求しない")
    func stopsAskingAfterTheLastPage() async {
        let state = FetchState<[Int]>()
        await state.runReload { [1] }

        await state.runMore { .last([1, 2]) }

        let before = state.id(of: .loadMore)
        state.request(.loadMore)

        #expect(state.id(of: .loadMore) == before)
        #expect(state.phase.loaded == [1, 2])
    }

    @Test("再取得すると終端の記憶は消える")
    func reloadForgetsTheEnd() async {
        let state = FetchState<[Int]>()
        await state.runReload { [1] }
        await state.runMore { .last([1, 2]) }

        state.request(.reload)
        await state.runReload { [1] }

        let before = state.id(of: .loadMore)
        state.request(.loadMore)

        #expect(state.id(of: .loadMore) != before)
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

    @Test("詳細の取り直しが重なっても、読み込めた続きは消えない")
    func loadMoreSurvivesAConcurrentRepair() async {
        let state = FetchState<[Int]>()
        await state.runReload { [1] }

        let more = Gate()
        let repair = Gate()

        let loadingMore = Task { await state.runMore { await more.wait(); return .more([1, 2]) } }
        await more.waitUntilEntered()

        let repairing = Task { await state.runRepair { await repair.wait(); return nil } }
        await repair.waitUntilEntered()

        more.open()
        await loadingMore.value

        repair.open()
        await repairing.value

        #expect(state.phase.loaded == [1, 2], "重なった取り直しに続きが押し流されている")
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

private final class Flag: @unchecked Sendable {
    private(set) var isRaised = false

    func raise() {
        isRaised = true
    }
}
