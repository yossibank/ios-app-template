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

    @Test("取得が失敗したら失敗状態になる")
    func failureBecomesFailed() async {
        let state = FetchState<[Int]>()

        await state.run { throw Boom() }

        #expect(state.phase.failure is Boom)
    }

    @Test("続きの取得が失敗しても、読み込めている分は消えない")
    func loadMoreFailureKeepsWhatWasLoaded() async {
        let state = FetchState<[Int]>()
        await state.run { [1, 2] }

        await state.runMore { throw Boom() }

        #expect(state.phase.loaded == [1, 2])
        #expect(state.isLoadingMore == false)
    }

    @Test("続きが無いと返ったら一覧はそのまま")
    func loadMoreNilKeepsList() async {
        let state = FetchState<[Int]>()
        await state.run { [1, 2] }

        await state.runMore { nil }

        #expect(state.phase.loaded == [1, 2])
        #expect(state.isLoadingMore == false)
    }

    @Test("読み込めていないうちは続きを取りにいかない")
    func loadMoreDoesNothingBeforeLoaded() async {
        let state = FetchState<[Int]>()
        var asked = false

        await state.runMore {
            asked = true
            return [9]
        }

        #expect(asked == false)
        #expect(state.phase.loaded == nil)
    }
}

private struct Boom: Error {}

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

    var failure: (any Error)? {
        guard case let .failed(error) = self else {
            return nil
        }

        return error
    }
}
