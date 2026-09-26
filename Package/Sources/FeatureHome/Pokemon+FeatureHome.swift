import Foundation
import SharedCore

extension Pokemon {
    var number: String {
        id.formatted(.number.grouping(.never).precision(.integerLength(3...)))
    }
}

extension [Pokemon] {
    func filtered(query: String) -> [Pokemon] {
        filter { query.isEmpty || $0.name.localizedStandardContains(query) }
    }
}
