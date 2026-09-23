import Foundation

struct FetchRequest {
    private(set) var id = UUID()

    private var served: UUID?

    mutating func renew() {
        id = UUID()
    }

    mutating func claim() -> Bool {
        guard served != id else {
            return false
        }

        served = id

        return true
    }

    mutating func release() {
        served = nil
    }
}
