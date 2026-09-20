@testable import ScreenCore
import Testing

struct ScreenStringsTests {
    @Test("文言はカタログから引かれる")
    func resolvesFromTheCatalog() {
        #expect(ScreenStrings.loadFailed == "読み込めませんでした")
        #expect(ScreenStrings.retry == "再取得")
    }
}
