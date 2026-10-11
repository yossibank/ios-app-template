import ScreenCore
import Testing

struct FetchFailureTests {
    @Test("失敗の文言はカタログから引かれる")
    func resolvesFromTheCatalog() {
        let unexpected = FetchFailure.unexpected(canRetry: true)

        #expect(FetchFailure.offline.message == "接続を確認してください")
        #expect(FetchFailure.timeout.message == "時間内に応答がありませんでした")
        #expect(FetchFailure.unreadable.message == "データを読み取れませんでした")
        #expect(unexpected.message == "予期しないエラーが発生しました")
    }

    @Test("サーバーエラーは状態コードを文言に含める")
    func serverErrorCarriesTheStatusCode() {
        let failure = FetchFailure.server(statusCode: 503, canRetry: true)
        #expect(failure.message == "サーバーが応答しませんでした（503）")
    }

    @Test("応答が遅いときは接続断とは別の文言になる")
    func timeoutIsNotOffline() {
        #expect(FetchFailure.timeout.message != FetchFailure.offline.message)
    }

    @Test("読み取れない応答は再試行できない")
    func unreadableCannotBeRetried() {
        #expect(!FetchFailure.unreadable.canRetry)
        #expect(FetchFailure.offline.canRetry)
        #expect(FetchFailure.timeout.canRetry)
    }

    @Test("認証切れだけがセッションの終わりを知らせる")
    func onlyUnauthorizedEndsTheSession() {
        let serverUnauthorized = FetchFailure.server(statusCode: 401, canRetry: false)

        #expect(FetchFailure.unauthorized.message == "ログインし直してください")
        #expect(FetchFailure.unauthorized.endsSession)
        #expect(!FetchFailure.unauthorized.canRetry)
        #expect(!FetchFailure.offline.endsSession)
        #expect(!serverUnauthorized.endsSession)
    }
}
