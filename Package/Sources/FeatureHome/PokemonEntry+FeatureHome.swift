import SharedCore

extension PokemonEntry {
    var loadedDetail: PokemonEntryDetailLoaded? {
        guard case let .loaded(detail) = onEnum(of: detail) else {
            return nil
        }

        return detail
    }

    var totalBaseStat: Int {
        loadedDetail.map { Int($0.totalBaseStat) } ?? -1
    }

    func matches(_ type: PokemonTypeKind?) -> Bool {
        guard let type else {
            return true
        }

        return loadedDetail?.types.contains(type) ?? false
    }
}

extension PokemonEntry: @retroactive Identifiable {}
