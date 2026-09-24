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

    @Test("すべてのキーがカタログから引ける")
    func everyKeyResolves() {
        for key in HomeStrings.Key.allCases {
            #expect(key.text != key.rawValue, "\(key.rawValue) の文言が引けていない")
        }
    }

    @Test("型の名前がすべてカタログから引ける")
    func everyKindResolves() {
        for kind in PokemonType.allCases {
            let name = HomeStrings.typeName(kind)
            #expect(!name.hasPrefix("home.type."), "\(kind) の文言が引けていない")
        }
    }

    @Test("能力の名前がすべてカタログから引ける")
    func everyStatKindResolves() {
        for kind in PokemonStat.allCases {
            let name = HomeStrings.statName(kind)
            #expect(!name.hasPrefix("home.stat."), "\(kind) の文言が引けていない")
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

    @Test("番号は 3 桁に揃える")
    func numbersArePadded() {
        #expect(HomeStrings.number(25) == "#025")
        #expect(HomeStrings.numberPlain(25) == "025")
        #expect(HomeStrings.number(1351) == "#1351")
    }

    @Test("進捗は読み込み済みと全体を順番どおりに並べる")
    func progressKeepsItsArgumentOrder() {
        #expect(HomeStrings.progress(loaded: 20, total: 1351) == "20 / 1351")
        #expect(HomeStrings.progressFiltered(shown: 3, total: 1351, loaded: 20)
            == "3 件（全 1351 件中 20 件読み込み済み）")
    }

    @Test("件数を渡す文言は数を落とさない")
    func countsSurviveFormatting() {
        #expect(HomeStrings.incomplete(7).contains("7"))
        #expect(HomeStrings.total(318) == "318")
    }
}
