@testable import ScreenCore
import Testing

struct ScreenStringsTests {
    @Test("文言はカタログから引かれる")
    func resolvesFromTheCatalog() {
        #expect(ScreenStrings.loadFailed == "読み込めませんでした")
        #expect(ScreenStrings.retry == "再取得")
        #expect(ScreenStrings.offline == "接続を確認してください")
        #expect(ScreenStrings.timeout == "時間内に応答がありませんでした")
        #expect(ScreenStrings.unreadable == "データを読み取れませんでした")
        #expect(ScreenStrings.unexpected == "予期しないエラーが発生しました")
    }

    @Test("すべてのキーがカタログから引ける")
    func everyKeyResolves() {
        for key in ScreenStrings.Key.allCases {
            #expect(key.text != key.rawValue, "\(key.rawValue) の文言が引けていない")
        }
    }

    @Test("サーバーエラーは状態コードを文言に含める")
    func serverErrorCarriesTheStatusCode() {
        #expect(ScreenStrings.serverError(statusCode: 503) == "サーバーが応答しませんでした（503）")
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
}
