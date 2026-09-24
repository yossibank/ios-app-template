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

        let filtered = pokemon.filtered(query: "char", type: nil, sort: .number)

        #expect(filtered.map(\.name) == ["charmander"])
    }

    @Test("名前の絞り込みは大文字小文字を区別しない")
    func nameFilterIgnoresCase() {
        let pokemon: [Pokemon] = [.fixture(id: 1, name: "bulbasaur")]

        #expect(pokemon.filtered(query: "BULBA", type: nil, sort: .number).count == 1)
    }

    @Test("型で絞り込む")
    func filtersByType() {
        let pokemon: [Pokemon] = [
            .fixture(id: 1, name: "bulbasaur", types: [.grass, .poison]),
            .fixture(id: 4, name: "charmander", types: [.fire])
        ]

        let filtered = pokemon.filtered(query: "", type: .fire, sort: .number)

        #expect(filtered.map(\.name) == ["charmander"])
    }

    @Test("詳細を取れていない行は型で絞ると残らない")
    func rowsWithoutDetailDropOutOfATypeFilter() {
        let pokemon: [Pokemon] = [
            .incomplete(id: 132, name: "ditto"),
            .fixture(id: 4, name: "charmander", types: [.fire])
        ]

        let filtered = pokemon.filtered(query: "", type: .fire, sort: .number)

        #expect(filtered.map(\.name) == ["charmander"])
    }

    @Test("絞り込んでいなければ詳細を取れていない行も残る")
    func rowsWithoutDetailStayWhenNothingIsFiltered() {
        let pokemon: [Pokemon] = [.incomplete(id: 132, name: "ditto")]

        #expect(pokemon.filtered(query: "", type: nil, sort: .number).count == 1)
    }

    @Test("番号の小さい順に並べる")
    func sortsByNumber() {
        let pokemon: [Pokemon] = [
            .fixture(id: 25, name: "pikachu"),
            .fixture(id: 1, name: "bulbasaur")
        ]

        #expect(pokemon.filtered(query: "", type: nil, sort: .number).map(\.id) == [1, 25])
    }

    @Test("合計の大きい順に並べる")
    func sortsByTotalDescending() {
        let pokemon: [Pokemon] = [
            .fixture(id: 1, name: "bulbasaur", baseStats: [PokemonBaseStat(kind: .hp, value: 300)]),
            .fixture(id: 4, name: "charmander", baseStats: [PokemonBaseStat(kind: .hp, value: 500)])
        ]

        #expect(pokemon.filtered(query: "", type: nil, sort: .total).map(\.name) == ["charmander", "bulbasaur"])
    }

    @Test("詳細を取れていない行は合計順で最後に回る")
    func rowsWithoutDetailSortLastByTotal() {
        let pokemon: [Pokemon] = [
            .incomplete(id: 132, name: "ditto"),
            .fixture(id: 1, name: "bulbasaur", baseStats: [PokemonBaseStat(kind: .hp, value: 300)])
        ]

        #expect(pokemon.filtered(query: "", type: nil, sort: .total).map(\.name) == ["bulbasaur", "ditto"])
    }

    @Test("名前順に並べる")
    func sortsByName() {
        let pokemon: [Pokemon] = [
            .fixture(id: 7, name: "squirtle"),
            .fixture(id: 1, name: "bulbasaur")
        ]

        let sorted = pokemon.filtered(query: "", type: nil, sort: .name)

        #expect(sorted.map(\.name) == ["bulbasaur", "squirtle"])
    }

    @Test("出てきた型を重複なく集める")
    func collectsTypesWithoutDuplicates() {
        let pokemon: [Pokemon] = [
            .fixture(id: 1, name: "bulbasaur", types: [.grass, .poison]),
            .fixture(id: 2, name: "ivysaur", types: [.grass, .poison]),
            .fixture(id: 4, name: "charmander", types: [.fire])
        ]

        #expect(pokemon.availableTypes == [.grass, .poison, .fire])
    }

    @Test("詳細を取れていない行の型は集めない")
    func doesNotCollectTypesFromRowsWithoutDetail() {
        let pokemon: [Pokemon] = [.incomplete(id: 132, name: "ditto")]

        #expect(pokemon.availableTypes.isEmpty)
    }
}
