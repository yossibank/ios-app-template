import SharedCore

enum PokemonSort: CaseIterable {
    case number
    case total
    case name

    var label: String {
        switch self {
        case .number: HomeStrings.sortNumber
        case .total: HomeStrings.sortTotal
        case .name: HomeStrings.sortName
        }
    }

    func areInIncreasingOrder(_ lhs: Pokemon, _ rhs: Pokemon) -> Bool {
        switch self {
        case .number: lhs.id < rhs.id
        case .total: lhs.totalBaseStat > rhs.totalBaseStat
        case .name: lhs.name < rhs.name
        }
    }
}
