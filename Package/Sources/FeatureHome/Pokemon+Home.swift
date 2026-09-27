import Foundation
import SharedCore

extension Pokemon {
    var number: String {
        id.formatted(.number.grouping(.never).precision(.integerLength(3...)))
    }
}

extension [Pokemon] {
    func filtered(query: String) -> [Pokemon] {
        let query = query.trimmingCharacters(in: .whitespacesAndNewlines)

        if query.isEmpty {
            return self
        }

        return filter {
            $0.name.localizedStandardContains(query)
        }
    }
}
