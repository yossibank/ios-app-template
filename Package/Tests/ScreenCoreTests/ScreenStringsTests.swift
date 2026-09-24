@testable import ScreenCore
import Testing

struct ScreenStringsTests {
    @Test("文言はカタログから引かれる")
    func resolvesFromTheCatalog() {
        #expect(ScreenStrings.loadFailed == "読み込めませんでした")
        #expect(ScreenStrings.retry == "再取得")
    }

    @Test("すべてのキーがカタログから引ける")
    func everyKeyResolves() {
        for key in ScreenStrings.Key.allCases {
            #expect(key.text != key.rawValue, "\(key.rawValue) の文言が引けていない")
        }
    }
}
