@testable import FeatureHome
import SharedCore
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
        #expect(HomeStrings.timeout == "時間内に応答がありませんでした")
        #expect(HomeStrings.unreadable == "データを読み取れませんでした")
        #expect(HomeStrings.unexpected == "予期しないエラーが発生しました")
    }

    @Test("型の名前がすべてカタログから引ける")
    func everyKindResolves() {
        for kind in PokemonTypeKind.allCases {
            let name = HomeStrings.typeName(kind)
            #expect(!name.hasPrefix("home.type."), "\(kind) の文言が引けていない")
        }
    }

    @Test("Android と語彙を揃えている型名")
    func typeNamesMatchAndroid() {
        #expect(HomeStrings.typeName(.grass) == "くさ")
        #expect(HomeStrings.typeName(.poison) == "どく")
    }

    @Test("サーバーエラーは状態コードを文言に含める")
    func serverErrorCarriesTheStatusCode() {
        #expect(HomeStrings.serverError(statusCode: 503) == "サーバーが応答しませんでした（503）")
    }
}
