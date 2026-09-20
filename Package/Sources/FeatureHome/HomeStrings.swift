import Foundation

enum HomeStrings {
    static var title: String {
        String(localized: "home.title", bundle: .module)
    }

    static var searchPrompt: String {
        String(localized: "home.search_prompt", bundle: .module)
    }

    static var emptyTitle: String {
        String(localized: "home.empty_title", bundle: .module)
    }

    static var emptyDescription: String {
        String(localized: "home.empty_description", bundle: .module)
    }

    static var reload: String {
        String(localized: "home.reload", bundle: .module)
    }

    static var offline: String {
        String(localized: "home.offline", bundle: .module)
    }

    static var unreadable: String {
        String(localized: "home.unreadable", bundle: .module)
    }

    static var unexpected: String {
        String(localized: "home.unexpected", bundle: .module)
    }

    static func serverError(statusCode: Int) -> String {
        String(
            format: String(localized: "home.server_error", bundle: .module),
            statusCode
        )
    }
}
