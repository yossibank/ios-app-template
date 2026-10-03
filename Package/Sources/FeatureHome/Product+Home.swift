import Foundation
import SharedCore

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
