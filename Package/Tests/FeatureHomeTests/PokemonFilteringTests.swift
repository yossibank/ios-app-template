@testable import FeatureHome
import SharedCore
import Testing

struct PokemonFilteringTests {
    @Test("名前で絞り込む")
    func filtersByName() {
        let pokemon: [Pokemon] = [
            .fixture(id: 1, name: "bulbasaur"),
            .fixture(id: 4, name: "charmander")
        ]

        #expect(pokemon.filtered(query: "char").map(\.name) == ["charmander"])
    }

    @Test("名前の絞り込みは大文字小文字を区別しない")
    func nameFilterIgnoresCase() {
        let pokemon: [Pokemon] = [.fixture(id: 1, name: "bulbasaur")]

        #expect(pokemon.filtered(query: "BULBA").count == 1)
    }

    @Test("絞り込んでいなければすべて残る")
    func emptyQueryKeepsEverything() {
        let pokemon: [Pokemon] = [
            .fixture(id: 1, name: "bulbasaur"),
            .fixture(id: 4, name: "charmander")
        ]

        #expect(pokemon.filtered(query: "").count == 2)
    }
}
