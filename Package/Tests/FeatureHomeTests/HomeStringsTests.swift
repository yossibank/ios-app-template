@testable import FeatureHome
import Testing

struct HomeStringsTests {
    @Test("文言はカタログから引かれる")
    func resolvesFromTheCatalog() {
        #expect(HomeStrings.title == "ポケモン")
        #expect(HomeStrings.searchPrompt == "名前で絞り込む")
        #expect(HomeStrings.emptyTitle == "ポケモンがいません")
        #expect(HomeStrings.emptyDescription == "取得できましたが 1 件もありませんでした")
        #expect(HomeStrings.reload == "再取得")
        #expect(HomeStrings.offline == "接続を確認してください")
        #expect(HomeStrings.unreadable == "データを読み取れませんでした")
        #expect(HomeStrings.unexpected == "予期しないエラーが発生しました")
    }

    @Test("サーバーエラーは状態コードを文言に含める")
    func serverErrorCarriesTheStatusCode() {
        #expect(HomeStrings.serverError(statusCode: 503) == "サーバーが応答しませんでした（503）")
    }
}
