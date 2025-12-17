//
//  AuthManager.swift
//  StartHub
//
//  Created by Олжас Сембинов on 17.12.2025.
//

//
//  AuthManager.swift
//  StartHub
//
//  PRIMARY RESPONSIBILITY: PERSON 1 (Authentication & Profile)
//  Used by: Everyone for checking auth status
//

import Foundation

class AuthManager {
    
    // MARK: - Singleton
    static let shared = AuthManager()
    
    // MARK: - UserDefaults Keys
    private let accessTokenKey = "accessToken"
    private let refreshTokenKey = "refreshToken"
    private let userIdKey = "userId"
    
    private init() {}
    
    // MARK: - Token Management
    
    /// Save tokens after successful login
    func saveTokens(accessToken: String, refreshToken: String? = nil) {
        UserDefaults.standard.set(accessToken, forKey: accessTokenKey)
        if let refreshToken = refreshToken {
            UserDefaults.standard.set(refreshToken, forKey: refreshTokenKey)
        }
    }
    
    /// Get access token
    func getAccessToken() -> String? {
        return UserDefaults.standard.string(forKey: accessTokenKey)
    }
    
    /// Get refresh token
    func getRefreshToken() -> String? {
        return UserDefaults.standard.string(forKey: refreshTokenKey)
    }
    
    /// Check if user is logged in
    func isLoggedIn() -> Bool {
        return getAccessToken() != nil
    }
    
    /// Clear all tokens (logout)
    func clearTokens() {
        UserDefaults.standard.removeObject(forKey: accessTokenKey)
        UserDefaults.standard.removeObject(forKey: refreshTokenKey)
        UserDefaults.standard.removeObject(forKey: userIdKey)
    }
    
    /// Save user ID
    func saveUserId(_ userId: Int) {
        UserDefaults.standard.set(userId, forKey: userIdKey)
    }
    
    /// Get user ID
    func getUserId() -> Int? {
        let userId = UserDefaults.standard.integer(forKey: userIdKey)
        return userId > 0 ? userId : nil
    }
    
    // MARK: - Login/Logout Methods (PERSON 1 implements these)
    
    /// Login user
    /// PERSON 1: Implement this method
    func login(email: String, password: String, completion: @escaping (Result<LoginResponse, NetworkError>) -> Void) {
        let parameters: [String: Any] = [
            "email": email,
            "password": password
        ]
        
        NetworkManager.shared.request(
            endpoint: APIEndpoints.Auth.login,
            method: .post,
            parameters: parameters,
            requiresAuth: false
        ) { (result: Result<LoginResponse, NetworkError>) in
            switch result {
            case .success(let response):
                // Save tokens
                self.saveTokens(accessToken: response.accessToken, refreshToken: response.refreshToken)
                if let userId = response.userId {
                    self.saveUserId(userId)
                }
                completion(.success(response))
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    /// Register new user
    /// PERSON 1: Implement this method
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
    
    /// Logout user
    /// PERSON 1: Implement this method
    func logout(completion: @escaping (Result<SuccessResponse, NetworkError>) -> Void) {
        NetworkManager.shared.request(
            endpoint: APIEndpoints.Auth.logout,
            method: .post,
            requiresAuth: true
        ) { (result: Result<SuccessResponse, NetworkError>) in
            // Clear tokens regardless of server response
            self.clearTokens()
            completion(result)
        }
    }
    
    /// Refresh access token
    /// PERSON 1: Optional - implement if needed
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
                self.saveTokens(accessToken: response.accessToken, refreshToken: response.refreshToken)
                completion(.success(response))
                
            case .failure(let error):
                self.clearTokens()
                completion(.failure(error))
            }
        }
    }
}

// MARK: - Response Models (PERSON 1)

struct LoginResponse: Codable {
    let accessToken: String
    let refreshToken: String?
    let tokenType: String?
    let expiresIn: Int?
    let userId: Int?
    let code: String?
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case tokenType = "token_type"
        case expiresIn = "expires_in"
        case userId = "user_id"
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
