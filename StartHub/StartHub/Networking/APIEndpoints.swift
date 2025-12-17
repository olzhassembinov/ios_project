//
//  APIEndpoints.swift
//  StartHub
//
//  Created by Олжас Сембинов on 15.12.2025.
//

//
//  APIEndpoints.swift
//  StartHub
//
//  Centralized API endpoint definitions
//

import Foundation

struct APIEndpoints {
    
    // MARK: - Base
    static let baseURL = "https://overfondly-bisymmetrical-jannette.ngrok-free.dev"
    
    // MARK: - Authentication Endpoints (PERSON 1)
    struct Auth {
        static let login = "/auth/login/"
        static let register = "/auth/register/"
        static let logout = "/auth/logout/"
        static let refreshToken = "/auth/refresh/"
        static let changePassword = "/auth/change-password/"
    }
    
    // MARK: - User/Profile Endpoints (PERSON 1)
    struct Profile {
        static let getCurrentUser = "/users/me/"
        static let updateProfile = "/users/me/"
        static let getUserById = "/users/" // append ID
        static let myProjects = "/projects/my-projects/"
    }
    
    // MARK: - Project Endpoints (PERSON 2)
    struct Projects {
        static let list = "/projects/"
        static let detail = "/projects/" // append ID
        static let create = "/projects/"
        static let update = "/projects/" // append ID
        static let delete = "/projects/" // append ID
        static let search = "/projects/search/"
        
        // Project components
        static let images = "/projects/images/"
        static let stages = "/projects/stages/"
        static let updateStage = "/projects/stages/" // append ID
    }
    
    // MARK: - Categories Endpoints (PERSON 2)
    struct Categories {
        static let list = "/categories/"
        static let detail = "/categories/" // append ID
    }
    
    // MARK: - Funding Models Endpoints (PERSON 2)
    struct FundingModels {
        static let list = "/funding-models/"
        static let detail = "/funding-models/" // append ID
        static let update = "/funding-models/" // append ID
    }
    
    // MARK: - Team Members Endpoints (PERSON 2)
    struct TeamMembers {
        static let list = "/team-members/"
        static let create = "/team-members/"
        static let delete = "/team-members/" // append ID
    }
    
    // MARK: - Social Links Endpoints (PERSON 2)
    struct SocialLinks {
        static let list = "/social-links/"
        static let create = "/social-links/"
        static let delete = "/social-links/" // append ID
    }
    
    // MARK: - Company Endpoints
    struct Company {
        static let list = "/companies/"
        static let detail = "/companies/" // append ID
    }
    
    // MARK: - Countries Endpoints
    struct Countries {
        static let list = "/countries/"
        static let detail = "/countries/" // append ID
    }
    
    // MARK: - Roles Endpoints
    struct Roles {
        static let list = "/roles/"
        static let detail = "/roles/" // append ID
    }
}

// MARK: - Endpoint Builder Helper
extension APIEndpoints {
    /// Helper to build endpoint with ID
    static func endpoint(base: String, id: Int) -> String {
        return "\(base)\(id)/"
    }
    
    /// Helper to build endpoint with multiple path components
    static func endpoint(base: String, components: [String]) -> String {
        return base + components.joined(separator: "/") + "/"
    }
}
