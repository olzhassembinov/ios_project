//
//  ProfileService.swift
//  StartHub
//
//  Created by Олжас Сембинов on 17.12.2025.
//

//
//  ProfileService.swift
//  StartHub
//
//  PRIMARY RESPONSIBILITY: PERSON 1 (Authentication & Profile)
//  Handles all profile-related API calls
//

import Foundation
import UIKit

class ProfileService {
    
    static let shared = ProfileService()
    private init() {}
    
    // MARK: - Get Current User Profile
    /// PERSON 1: Use this to fetch logged-in user's profile
    func getCurrentUserProfile(completion: @escaping (Result<User, NetworkError>) -> Void) {
        NetworkManager.shared.request(
            endpoint: APIEndpoints.Profile.getCurrentUser,
            method: .get,
            requiresAuth: true,
            completion: completion
        )
    }
    
    // MARK: - Update User Profile
    /// PERSON 1: Use this to update user profile information
    func updateProfile(
        name: String? = nil,
        surname: String? = nil,
        email: String? = nil,
        completion: @escaping (Result<User, NetworkError>) -> Void
    ) {
        var parameters: [String: Any] = [:]
        
        if let name = name {
            parameters["name"] = name
        }
        if let surname = surname {
            parameters["surname"] = surname
        }
        if let email = email {
            parameters["email"] = email
        }
        
        NetworkManager.shared.request(
            endpoint: APIEndpoints.Profile.updateProfile,
            method: .patch,
            parameters: parameters,
            requiresAuth: true,
            completion: completion
        )
    }
    
    // MARK: - Get User by ID
    /// Get any user's public profile by ID
    func getUserById(userId: Int, completion: @escaping (Result<User, NetworkError>) -> Void) {
        let endpoint = APIEndpoints.endpoint(base: APIEndpoints.Profile.getUserById, id: userId)
        
        NetworkManager.shared.request(
            endpoint: endpoint,
            method: .get,
            requiresAuth: true,
            completion: completion
        )
    }
    
    // MARK: - Get My Projects
    /// PERSON 1: Use this to fetch projects created by logged-in user
    func getMyProjects(completion: @escaping (Result<ProjectListResponse, NetworkError>) -> Void) {
        NetworkManager.shared.request(
            endpoint: APIEndpoints.Profile.myProjects,
            method: .get,
            requiresAuth: true,
            completion: completion
        )
    }
    
    // MARK: - Upload Profile Picture
    /// PERSON 1: Optional - Upload user profile picture
    func uploadProfilePicture(image: UIImage, completion: @escaping (Result<User, NetworkError>) -> Void) {
        NetworkManager.shared.uploadImage(
            endpoint: APIEndpoints.Profile.updateProfile,
            image: image,
            paramName: "picture",
            requiresAuth: true
        ) { result in
            switch result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let user = try decoder.decode(User.self, from: data)
                    completion(.success(user))
                } catch {
                    completion(.failure(.decodingError(error)))
                }
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
