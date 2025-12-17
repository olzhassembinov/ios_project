//
//  AuthManager.swift
//  StartHub
//

import Foundation

class AuthManager {
    
    static let shared = AuthManager()
    
    private let accessTokenKey = "accessToken"
    private let refreshTokenKey = "refreshToken"
    private let userIdKey = "userId"
    
    private init() {}
    
    func saveTokens(accessToken: String, refreshToken: String? = nil) {
        UserDefaults.standard.set(accessToken, forKey: accessTokenKey)
        if let refreshToken = refreshToken {
            UserDefaults.standard.set(refreshToken, forKey: refreshTokenKey)
        }
        print("✅ Token saved: \(accessToken.prefix(20))...")
    }
    
    func getAccessToken() -> String? {
        return UserDefaults.standard.string(forKey: accessTokenKey)
    }
    
    func getRefreshToken() -> String? {
        return UserDefaults.standard.string(forKey: refreshTokenKey)
    }
    
    func isLoggedIn() -> Bool {
        return getAccessToken() != nil
    }
    
    func clearTokens() {
        UserDefaults.standard.removeObject(forKey: accessTokenKey)
        UserDefaults.standard.removeObject(forKey: refreshTokenKey)
        UserDefaults.standard.removeObject(forKey: userIdKey)
        print("🗑️ Tokens cleared")
    }
    
    func saveUserId(_ userId: Int) {
        UserDefaults.standard.set(userId, forKey: userIdKey)
    }
    
    func getUserId() -> Int? {
        let userId = UserDefaults.standard.integer(forKey: userIdKey)
        return userId > 0 ? userId : nil
    }
    
    // MARK: - Login (Custom Implementation)
    func login(email: String, password: String, completion: @escaping (Result<LoginResponse, NetworkError>) -> Void) {
        let parameters: [String: Any] = [
            "email": email,
            "password": password
        ]
        
        // Use NetworkManager's custom request without auto snake_case conversion
        NetworkManager.shared.requestWithoutSnakeCaseConversion(
            endpoint: APIEndpoints.Auth.login,
            method: .post,
            parameters: parameters,
            requiresAuth: false
        ) { [weak self] (result: Result<LoginResponse, NetworkError>) in
            switch result {
            case .success(let response):
                self?.saveTokens(accessToken: response.accessToken)
                print("✅ Login successful!")
                completion(.success(response))
                
            case .failure(let error):
                print("❌ Login failed: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
    }
    
    func register(name: String, email: String, password: String, passwordConfirmation: String, completion: @escaping (Result<RegisterResponse, NetworkError>) -> Void) {
        let parameters: [String: Any] = [
            "name": name,
            "email": email,
            "password": password,
            "password_confirmation": passwordConfirmation
        ]
        
        NetworkManager.shared.request(
            endpoint: APIEndpoints.Auth.register,
            method: .post,
            parameters: parameters,
            requiresAuth: false,
            completion: completion
        )
    }
    
    func logout(completion: @escaping (Result<SuccessResponse, NetworkError>) -> Void) {
        NetworkManager.shared.request(
            endpoint: APIEndpoints.Auth.logout,
            method: .post,
            requiresAuth: true
        ) { (result: Result<SuccessResponse, NetworkError>) in
            self.clearTokens()
            completion(result)
        }
    }
    
    func refreshAccessToken(completion: @escaping (Result<LoginResponse, NetworkError>) -> Void) {
        guard let refreshToken = getRefreshToken() else {
            completion(.failure(.unauthorized))
            return
        }
        
        let parameters: [String: Any] = [
            "refresh_token": refreshToken
        ]
        
        NetworkManager.shared.request(
            endpoint: APIEndpoints.Auth.refreshToken,
            method: .post,
            parameters: parameters,
            requiresAuth: false
        ) { (result: Result<LoginResponse, NetworkError>) in
            switch result {
            case .success(let response):
                self.saveTokens(accessToken: response.accessToken)
                completion(.success(response))
                
            case .failure(let error):
                self.clearTokens()
                completion(.failure(error))
            }
        }
    }
}

// MARK: - Response Models
struct LoginResponse: Codable {
    let accessToken: String
    let code: String?
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case code
    }
}

struct RegisterResponse: Codable {
    let code: String?
    let message: String?
    let userId: Int?
    
    enum CodingKeys: String, CodingKey {
        case code
        case message
        case userId = "user_id"
    }
}

struct SuccessResponse: Codable {
    let code: String
    let message: String?
}
