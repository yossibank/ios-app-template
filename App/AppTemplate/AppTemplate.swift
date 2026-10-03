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
        AppRootView.configure(baseURL: "https://dummyjson.com")
    }
}
