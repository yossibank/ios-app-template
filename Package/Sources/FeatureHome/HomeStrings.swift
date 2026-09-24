import Foundation
import SharedCore

enum HomeStrings {
    static var title: String {
        Key.title.text
    }

    static var searchPrompt: String {
        Key.searchPrompt.text
    }

    static var emptyTitle: String {
        Key.emptyTitle.text
    }

    static var emptyDescription: String {
        Key.emptyDescription.text
    }

    static var reload: String {
        Key.reload.text
    }

    static var offline: String {
        Key.offline.text
    }

    static var timeout: String {
        Key.timeout.text
    }

    static var unreadable: String {
        Key.unreadable.text
    }

    static var unexpected: String {
        Key.unexpected.text
    }

    static var totalCaption: String {
        Key.totalCaption.text
    }

    static var retryDetails: String {
        Key.retryDetails.text
    }

    static var sortTitle: String {
        Key.sortTitle.text
    }

    static var sortNumber: String {
        Key.sortNumber.text
    }

    static var sortTotal: String {
        Key.sortTotal.text
    }

    static var sortName: String {
        Key.sortName.text
    }

    static var filterAll: String {
        Key.filterAll.text
    }

    static var noTypeMatch: String {
        Key.noTypeMatch.text
    }

    static var noTypeMatchDescription: String {
        Key.noTypeMatchDescription.text
    }

    static var detailMissing: String {
        Key.detailMissing.text
    }

    static func serverError(statusCode: Int) -> String {
        String(format: Key.serverError.text, statusCode)
    }

    static func incomplete(_ count: Int) -> String {
        String(format: Key.incomplete.text, count)
    }

    static func number(_ id: Int) -> String {
        String(format: Key.number.text, id)
    }

    static func numberPlain(_ id: Int) -> String {
        String(format: Key.numberPlain.text, id)
    }

    static func total(_ value: Int) -> String {
        String(format: Key.total.text, value)
    }

    static func progress(loaded: Int, total: Int) -> String {
        String(format: Key.progress.text, loaded, total)
    }

    static func progressFiltered(shown: Int, total: Int, loaded: Int) -> String {
        String(format: Key.progressFiltered.text, shown, total, loaded)
    }

    static func statName(_ stat: PokemonStat) -> String {
        Key(stat).text
    }

    static func typeName(_ type: PokemonType) -> String {
        Key(type).text
    }
}

extension HomeStrings {
    enum Key: String, CaseIterable {
        case title = "home.title"
        case searchPrompt = "home.search_prompt"
        case emptyTitle = "home.empty_title"
        case emptyDescription = "home.empty_description"
        case reload = "home.reload"
        case offline = "home.offline"
        case timeout = "home.timeout"
        case unreadable = "home.unreadable"
        case unexpected = "home.unexpected"
        case serverError = "home.server_error"
        case incomplete = "home.incomplete"
        case retryDetails = "home.retry_details"
        case number = "home.number"
        case numberPlain = "home.number_plain"
        case total = "home.total"
        case totalCaption = "home.total_caption"
        case progress = "home.progress"
        case progressFiltered = "home.progress_filtered"
        case sortTitle = "home.sort.title"
        case sortNumber = "home.sort.number"
        case sortTotal = "home.sort.total"
        case sortName = "home.sort.name"
        case filterAll = "home.filter_all"
        case noTypeMatch = "home.no_type_match"
        case noTypeMatchDescription = "home.no_type_match_description"
        case detailMissing = "home.detail_missing"
        case statHp = "home.stat.hp"
        case statAttack = "home.stat.attack"
        case statDefense = "home.stat.defense"
        case statSpecialAttack = "home.stat.special_attack"
        case statSpecialDefense = "home.stat.special_defense"
        case statSpeed = "home.stat.speed"
        case statOther = "home.stat.other"
        case typeNormal = "home.type.normal"
        case typeFire = "home.type.fire"
        case typeWater = "home.type.water"
        case typeElectric = "home.type.electric"
        case typeGrass = "home.type.grass"
        case typeIce = "home.type.ice"
        case typeFighting = "home.type.fighting"
        case typePoison = "home.type.poison"
        case typeGround = "home.type.ground"
        case typeFlying = "home.type.flying"
        case typePsychic = "home.type.psychic"
        case typeBug = "home.type.bug"
        case typeRock = "home.type.rock"
        case typeGhost = "home.type.ghost"
        case typeDragon = "home.type.dragon"
        case typeDark = "home.type.dark"
        case typeSteel = "home.type.steel"
        case typeFairy = "home.type.fairy"
        case typeUnknown = "home.type.unknown"
    }
}

extension HomeStrings.Key {
    var text: String {
        String(localized: String.LocalizationValue(stringLiteral: rawValue), bundle: .module)
    }

    init(_ stat: PokemonStat) {
        self = switch stat {
        case .hp: .statHp
        case .attack: .statAttack
        case .defense: .statDefense
        case .specialAttack: .statSpecialAttack
        case .specialDefense: .statSpecialDefense
        case .speed: .statSpeed
        case .other: .statOther
        }
    }

    init(_ type: PokemonType) {
        self = switch type {
        case .normal: .typeNormal
        case .fire: .typeFire
        case .water: .typeWater
        case .electric: .typeElectric
        case .grass: .typeGrass
        case .ice: .typeIce
        case .fighting: .typeFighting
        case .poison: .typePoison
        case .ground: .typeGround
        case .flying: .typeFlying
        case .psychic: .typePsychic
        case .bug: .typeBug
        case .rock: .typeRock
        case .ghost: .typeGhost
        case .dragon: .typeDragon
        case .dark: .typeDark
        case .steel: .typeSteel
        case .fairy: .typeFairy
        case .unknown: .typeUnknown
        }
    }
}
