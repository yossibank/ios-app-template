import AppRoot
import SwiftUI

@main
struct AppTemplate: App {
    var body: some Scene {
        WindowGroup {
            AppRootView()
        }
    }

    init() {
        guard let baseURL = Bundle.main.object(forInfoDictionaryKey: "APIBaseURL") as? String else {
            fatalError("Info.plist に APIBaseURL がありません")
        }

        AppRootView.configure(baseURL: baseURL)
    }
}
