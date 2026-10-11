@testable import FeatureHome
import Foundation
import SharedCore
import Testing

struct ProductListChaptersTests {
    @Test("読み込んだ分を 1 回の取得件数ごとの章に分ける")
    func productsAreSplitIntoChaptersByPageSize() {
        let chapters = list(count: 45, total: 194).chapters

        #expect(chapters.map(\.numeral) == ["I", "II", "III"])
        #expect(chapters.map(\.first) == [1, 21, 41])
        #expect(chapters.map(\.last) == [20, 40, 60])
    }

    @Test("最後の章の終わりは総件数を超えない")
    func theLastChapterEndsAtTheTotal() {
        let chapters = list(count: 194, total: 194).chapters

        #expect(chapters.last?.first == 181)
        #expect(chapters.last?.last == 194)
    }

    @Test("章の中は大きい 1 件と小さい 2 件を繰り返し、余りは小さい側に回す")
    func chaptersRepeatOneLeadAndAPair() {
        let spreads = list(count: 20, total: 194).chapters[0].spreads

        #expect(spreads.map(\.lead.id) == [1, 4, 7, 10, 13, 16, 19])
        #expect(spreads.map(\.pair.count) == [2, 2, 2, 2, 2, 2, 1])
    }

    @Test("読み込み中の章は、今の章が埋まっているときだけ次の番号で出す")
    func theNextChapterIsKnownOnlyAfterAFullChapter() {
        let next = list(count: 40, total: 194).nextChapter
        let nextAfterPartialChapter = list(count: 45, total: 194).nextChapter

        #expect(next?.index == 2)
        #expect(next?.first == 41)
        #expect(next?.last == 60)
        #expect(nextAfterPartialChapter == nil)
    }

    @Test("章の番号はローマ数字になる")
    func numeralsAreRoman() {
        let numerals = [1, 4, 9, 10, 14, 40].map(Chapter.numeral)
        #expect(numerals == ["I", "IV", "IX", "X", "XIV", "XL"])
    }

    @Test("商品番号は 3 桁にそろえる")
    func numbersArePaddedToThreeDigits() {
        let small = product(id: 6)
        let large = product(id: 194)

        #expect(small.number == "NO. 006")
        #expect(large.number == "NO. 194")
    }

    @Test("価格は日本語の環境でもドルで小数 2 桁まで出す")
    func pricesAreShownInDollars() {
        let product = Product(
            id: 6,
            title: "Calvin Klein CK One",
            thumbnail: nil,
            brand: nil,
            price: 49.99
        )

        let japanese = Locale(identifier: "ja_JP")
        let english = Locale(identifier: "en_US")

        let japaneseText = product.priceText(locale: japanese)
        let englishText = product.priceText(locale: english)

        #expect(japaneseText == "$49.99")
        #expect(englishText == "$49.99")
    }
}

private extension ProductListChaptersTests {
    func list(
        count: Int,
        total: Int
    ) -> ProductList {
        let products = (1...count).map(product)

        return ProductList(
            products: products,
            total: total,
            pageSize: 20
        )
    }

    func product(id: Int) -> Product {
        Product(
            id: id,
            title: "p\(id)",
            thumbnail: nil,
            brand: nil,
            price: 1
        )
    }
}
