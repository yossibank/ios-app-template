import Foundation

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

    static var sortTitle: String {
        Key.sortTitle.text
    }

    static var sortNumber: String {
        Key.sortNumber.text
    }

    static var sortName: String {
        Key.sortName.text
    }

    static func number(_ id: Int) -> String {
        String(format: Key.number.text, id)
    }

    static func numberPlain(_ id: Int) -> String {
        String(format: Key.numberPlain.text, id)
    }

    static func progress(loaded: Int, total: Int) -> String {
        String(format: Key.progress.text, loaded, total)
    }

    static func progressFiltered(shown: Int, total: Int, loaded: Int) -> String {
        String(format: Key.progressFiltered.text, shown, total, loaded)
    }
}

extension HomeStrings {
    enum Key: String, CaseIterable {
        case title = "home.title"
        case searchPrompt = "home.search_prompt"
        case emptyTitle = "home.empty_title"
        case emptyDescription = "home.empty_description"
        case reload = "home.reload"
        case number = "home.number"
        case numberPlain = "home.number_plain"
        case progress = "home.progress"
        case progressFiltered = "home.progress_filtered"
        case sortTitle = "home.sort.title"
        case sortNumber = "home.sort.number"
        case sortName = "home.sort.name"
    }
}

extension HomeStrings.Key {
    var text: String {
        String(localized: String.LocalizationValue(stringLiteral: rawValue), bundle: .module)
    }
}
