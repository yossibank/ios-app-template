import Shared

public enum Account {
    public static var isLoggedIn: Bool {
        Session.shared.isLoggedIn
    }

    public static func configure(baseURL: String) {
        Session.shared.configure(baseUrl: baseURL)
    }

    public static func logout() {
        Session.shared.logout()
    }
}
