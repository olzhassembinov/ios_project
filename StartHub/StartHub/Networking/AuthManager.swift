import Foundation

final class AuthManager {
    static let shared = AuthManager()
    private init() {}

    private let accessKey = "auth.access"
    private let refreshKey = "auth.refresh"

    func saveTokens(access: String, refresh: String) {
        UserDefaults.standard.set(access, forKey: accessKey)
        UserDefaults.standard.set(refresh, forKey: refreshKey)
    }

    func getAccessToken() -> String? {
        UserDefaults.standard.string(forKey: accessKey)
    }

    func getRefreshToken() -> String? {
        UserDefaults.standard.string(forKey: refreshKey)
    }

    func clearTokens() {
        UserDefaults.standard.removeObject(forKey: accessKey)
        UserDefaults.standard.removeObject(forKey: refreshKey)
    }

    var isLoggedIn: Bool {
        getAccessToken() != nil
    }
}

