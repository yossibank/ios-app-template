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

        #expect(pokemon.filtered(query: "char", sort: .number).map(\.name) == ["charmander"])
    }

    @Test("名前の絞り込みは大文字小文字を区別しない")
    func nameFilterIgnoresCase() {
        let pokemon: [Pokemon] = [.fixture(id: 1, name: "bulbasaur")]

        #expect(pokemon.filtered(query: "BULBA", sort: .number).count == 1)
    }

    @Test("絞り込んでいなければすべて残る")
    func emptyQueryKeepsEverything() {
        let pokemon: [Pokemon] = [
            .fixture(id: 1, name: "bulbasaur"),
            .fixture(id: 4, name: "charmander")
        ]

        #expect(pokemon.filtered(query: "", sort: .number).count == 2)
    }

    @Test("番号の小さい順に並べる")
    func sortsByNumber() {
        let pokemon: [Pokemon] = [
            .fixture(id: 25, name: "pikachu"),
            .fixture(id: 1, name: "bulbasaur")
        ]

        #expect(pokemon.filtered(query: "", sort: .number).map(\.id) == [1, 25])
    }

    @Test("名前順に並べる")
    func sortsByName() {
        let pokemon: [Pokemon] = [
            .fixture(id: 7, name: "squirtle"),
            .fixture(id: 1, name: "bulbasaur")
        ]

        #expect(pokemon.filtered(query: "", sort: .name).map(\.name) == ["bulbasaur", "squirtle"])
    }
}
