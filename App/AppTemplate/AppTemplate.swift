import AppRoot
import SwiftUI

@main
@MainActor
struct AppTemplate {
    init() {
        guard let baseURL = Bundle.main.object(forInfoDictionaryKey: "APIBaseURL") as? String else {
            fatalError("Info.plist に APIBaseURL がありません")
        }

        AppRootView.configure(baseURL: baseURL)
    }
}

extension AppTemplate: App {
    var body: some Scene {
        WindowGroup {
            AppRootView()
        }
    }
}
