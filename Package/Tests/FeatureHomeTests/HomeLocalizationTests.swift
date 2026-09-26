@testable import FeatureHome
import Foundation
import SharedCore
import Testing

struct HomeLocalizationTests {
    @Test("番号は 3 桁に揃え、桁区切りを入れない")
    func numbersArePadded() {
        #expect(String(localized: .homeNumber(Pokemon.fixture(id: 25, name: "a").number)) == "#025")
        #expect(String(localized: .homeNumberPlain(Pokemon.fixture(id: 25, name: "a").number)) ==
            "025")
        #expect(String(localized: .homeNumber(Pokemon.fixture(id: 1351, name: "a").number)) ==
            "#1351")
    }

    @Test("進捗は読み込み済みと全体を順番どおりに並べ、桁区切りを入れない")
    func progressKeepsItsArgumentOrder() {
        #expect(String(localized: .homeProgress(20.ungrouped, 1351.ungrouped)) == "20 / 1351")
        #expect(String(localized: .homeProgressFiltered(3.ungrouped, 1351.ungrouped, 20.ungrouped))
            == "3 件（全 1351 件中 20 件読み込み済み）")
    }
}
