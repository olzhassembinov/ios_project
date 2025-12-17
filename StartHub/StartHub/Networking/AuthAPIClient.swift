import Foundation

final class AuthAPIClient {
    static let shared = AuthAPIClient()
    private init() {}

    func login(username: String, password: String, completion: @escaping (Result<TokenPair, NetworkError>) -> Void) {
        NetworkManager.shared.request(
            endpoint: AuthEndpoints.token,
            method: .post,
            parameters: ["username": username, "password": password],
            requiresAuth: false,
            completion: completion
        )
    }

    func register(email: String, password: String, completion: @escaping (Result<Void, NetworkError>) -> Void) {
        NetworkManager.shared.requestVoid(
            endpoint: AuthEndpoints.register,
            method: .post,
            parameters: ["email": email, "username": email, "password": password],
            requiresAuth: false,
            completion: completion
        )
    }

    func me(completion: @escaping (Result<MeResponse, NetworkError>) -> Void) {
        NetworkManager.shared.request(
            endpoint: AuthEndpoints.me,
            method: .get,
            parameters: nil,
            requiresAuth: true,
            completion: completion
        )
    }

    func refresh(completion: @escaping (Result<AccessTokenResponse, NetworkError>) -> Void) {
        guard let refresh = AuthManager.shared.getRefreshToken() else {
            completion(.failure(.unauthorized))
            return
        }
        NetworkManager.shared.request(
            endpoint: AuthEndpoints.refresh,
            method: .post,
            parameters: ["refresh": refresh],
            requiresAuth: false,
            completion: completion
        )
    }
}
