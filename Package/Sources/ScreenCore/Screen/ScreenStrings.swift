import Foundation

enum ScreenStrings {
    static var loadFailed: String {
        Key.loadFailed.text
    }

    static var retry: String {
        Key.retry.text
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

    static func serverError(statusCode: Int) -> String {
        String(format: Key.serverError.text, statusCode)
    }
}

extension ScreenStrings {
    enum Key: String, CaseIterable {
        case loadFailed = "screen.load_failed"
        case retry = "screen.retry"
        case offline = "screen.offline"
        case timeout = "screen.timeout"
        case unreadable = "screen.unreadable"
        case unexpected = "screen.unexpected"
        case serverError = "screen.server_error"
    }
}

extension ScreenStrings.Key {
    var text: String {
        String(localized: String.LocalizationValue(stringLiteral: rawValue), bundle: .module)
    }
}
