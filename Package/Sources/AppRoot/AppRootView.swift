import FeatureHome
import FeatureLogin
import ScreenCore
import SharedCore
import SwiftUI

@MainActor
public struct AppRootView {
    @State private var isLoggedIn = Account.isLoggedIn

    public init() {}
}

public extension AppRootView {
    static func configure(baseURL: String) {
        Account.configure(baseURL: baseURL)
    }
}

extension AppRootView: View {
    public var body: some View {
        if isLoggedIn {
            NavigationStack {
                HomeView {
                    Account.logout()
                    isLoggedIn = false
                }
            }
            .onSessionEnded {
                isLoggedIn = false
            }
        } else {
            LoginView {
                isLoggedIn = true
            }
        }
    }
}
