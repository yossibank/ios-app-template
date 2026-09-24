import SharedCore

enum PokemonSort: CaseIterable {
    case number
    case name

    var label: String {
        switch self {
        case .number: HomeStrings.sortNumber
        case .name: HomeStrings.sortName
        }
    }

    func areInIncreasingOrder(_ lhs: Pokemon, _ rhs: Pokemon) -> Bool {
        switch self {
        case .number: lhs.id < rhs.id
        case .name: lhs.name < rhs.name
        }
    }
}
