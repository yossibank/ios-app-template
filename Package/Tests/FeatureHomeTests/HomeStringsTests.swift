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
    }

    @Test("すべてのキーがカタログから引ける")
    func everyKeyResolves() {
        for key in HomeStrings.Key.allCases {
            #expect(key.text != key.rawValue, "\(key.rawValue) の文言が引けていない")
        }
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
}
