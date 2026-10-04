import Foundation
import ScreenCore
import SharedCore
import SwiftUI

extension [Product] {
    func filtered(query: String) -> [Product] {
        let query = query.trimmingCharacters(in: .whitespacesAndNewlines)

        if query.isEmpty {
            return self
        }

        return filter {
            $0.title.localizedStandardContains(query)
        }
    }
}

extension Product {
    var number: String {
        String(localized: .homeProductNumber(String(format: "%03d", id)))
    }

    func priceText(locale: Locale = .current) -> String {
        price.formatted(.currency(code: "USD").locale(locale))
    }

    func highlightedTitle(matching query: String) -> AttributedString {
        var text = AttributedString(title)
        let query = query.trimmingCharacters(in: .whitespacesAndNewlines)

        if
            let range = title.localizedStandardRange(of: query),
            let marked = Range(range, in: text) {
            text[marked].backgroundColor = .atelierMark
        }

        return text
    }
}

struct Chapter: Identifiable {
    let index: Int
    let first: Int
    let last: Int
    let spreads: [Spread]

    var id: Int {
        index
    }

    var numeral: String {
        Chapter.numeral(index + 1)
    }

    static func numeral(_ value: Int) -> String {
        let symbols = [
            (1000, "M"), (900, "CM"), (500, "D"), (400, "CD"),
            (100, "C"), (90, "XC"), (50, "L"), (40, "XL"),
            (10, "X"), (9, "IX"), (5, "V"), (4, "IV"), (1, "I")
        ]
        var rest = value

        return symbols.reduce(into: "") { text, symbol in
            while rest >= symbol.0 {
                text += symbol.1
                rest -= symbol.0
            }
        }
    }
}

struct Spread: Identifiable {
    let lead: Product
    let pair: [Product]

    var id: Product.ID {
        lead.id
    }
}

extension ProductList {
    var chapters: [Chapter] {
        stride(from: 0, to: products.count, by: pageSize).map { start in
            let products = Array(products[start..<Swift.min(start + pageSize, products.count)])

            return Chapter(
                index: start / pageSize,
                first: start + 1,
                last: Swift.min(start + pageSize, total),
                spreads: stride(from: 0, to: products.count, by: 3).map { offset in
                    Spread(
                        lead: products[offset],
                        pair: Array(products[(offset + 1)..<Swift.min(offset + 3, products.count)])
                    )
                }
            )
        }
    }

    var nextChapter: Chapter? {
        guard products.count % pageSize == 0 else {
            return nil
        }

        return Chapter(
            index: products.count / pageSize,
            first: products.count + 1,
            last: Swift.min(products.count + pageSize, total),
            spreads: []
        )
    }
}
