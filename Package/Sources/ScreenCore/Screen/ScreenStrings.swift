import Foundation

enum ScreenStrings {
    static var loadFailed: String {
        Key.loadFailed.text
    }

    static var retry: String {
        Key.retry.text
    }
}

extension ScreenStrings {
    enum Key: String, CaseIterable {
        case loadFailed = "screen.load_failed"
        case retry = "screen.retry"
    }
}

extension ScreenStrings.Key {
    var text: String {
        String(localized: String.LocalizationValue(stringLiteral: rawValue), bundle: .module)
    }
}
