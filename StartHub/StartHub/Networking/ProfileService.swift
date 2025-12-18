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
    func getCurrentUserProfile(completion: @escaping (Result<User, NetworkError>) -> Void) {
        print("📱 Loading current user profile...")
        
        NetworkManager.shared.requestWithoutSnakeCaseConversion(
            endpoint: APIEndpoints.Profile.getCurrentUser,
            method: .get,
            requiresAuth: true,
            completion: completion
        )
    }
    
    // MARK: - Update Profile
    func updateProfile(name: String?, surname: String?, email: String?, completion: @escaping (Result<User, NetworkError>) -> Void) {
        var parameters: [String: Any] = [:]
        if let name = name { parameters["name"] = name }
        if let surname = surname { parameters["surname"] = surname }
        if let email = email { parameters["email"] = email }
        
        NetworkManager.shared.requestWithoutSnakeCaseConversion(
            endpoint: APIEndpoints.Profile.updateProfile,
            method: .patch,
            parameters: parameters,
            requiresAuth: true,
            completion: completion
        )
    }
    
    // MARK: - Get User by ID
    func getUserById(userId: Int, completion: @escaping (Result<User, NetworkError>) -> Void) {
        let endpoint = "\(APIEndpoints.Profile.getUserById)\(userId)/"
        
        NetworkManager.shared.requestWithoutSnakeCaseConversion(
            endpoint: endpoint,
            method: .get,
            requiresAuth: true,
            completion: completion
        )
    }
    
    // MARK: - Get My Projects
    func getMyProjects(completion: @escaping (Result<ProjectListResponse, NetworkError>) -> Void) {
        NetworkManager.shared.requestWithoutSnakeCaseConversion(
            endpoint: APIEndpoints.Profile.myProjects,
            method: .get,
            requiresAuth: true,
            completion: completion
        )
    }
    
    // MARK: - Upload Profile Picture (Optional)
    func uploadProfilePicture(image: UIImage, completion: @escaping (Result<Data, NetworkError>) -> Void) {
        NetworkManager.shared.uploadImage(
            endpoint: APIEndpoints.Profile.updateProfile,
            image: image,
            paramName: "picture",
            requiresAuth: true,
            completion: completion
        )
    }
}
