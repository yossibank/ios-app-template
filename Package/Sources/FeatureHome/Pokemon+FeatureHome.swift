import Foundation
import SharedCore

extension [Pokemon] {
    func filtered(query: String) -> [Pokemon] {
        filter { query.isEmpty || $0.name.localizedStandardContains(query) }
    }
}
