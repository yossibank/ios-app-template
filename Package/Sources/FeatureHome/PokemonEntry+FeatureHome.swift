import ScreenCore
import SharedCore
import SwiftUI

extension PokemonEntry {
    func matches(_ type: PokemonTypeKind?) -> Bool {
        guard let type else {
            return true
        }

        guard case let .loaded(detail) = onEnum(of: detail) else {
            return false
        }

        return detail.types.contains(type)
    }
}

extension PokemonEntry: @retroactive Identifiable {}
