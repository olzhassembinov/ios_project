//
//  ProjectService.swift
//  StartHub
//
//  PRIMARY RESPONSIBILITY: PERSON 2 (Catalogue)
//  Handles all project-related API calls
//

import Foundation

class ProjectService {
    
    static let shared = ProjectService()
    private init() {}
    
    // MARK: - Get All Projects (Catalogue)
    func getAllProjects(
        page: Int = 1,
        pageSize: Int = 20,
        completion: @escaping (Result<ProjectListResponse, NetworkError>) -> Void
    ) {
        var endpoint = APIEndpoints.Projects.list
        endpoint += "?page=\(page)&page_size=\(pageSize)"
        
        NetworkManager.shared.request(
            endpoint: endpoint,
            method: .get,
            requiresAuth: false, // Catalogue is public
            completion: completion
        )
    }
    
    // MARK: - Get Project by ID (Detail View)
    func getProjectById(projectId: Int, completion: @escaping (Result<Project, NetworkError>) -> Void) {
        let endpoint = APIEndpoints.endpoint(base: APIEndpoints.Projects.detail, id: projectId)
        
        NetworkManager.shared.request(
            endpoint: endpoint,
            method: .get,
            requiresAuth: false,
            completion: completion
        )
    }
    
    // MARK: - Search Projects
    func searchProjects(
        query: String,
        completion: @escaping (Result<ProjectListResponse, NetworkError>) -> Void
    ) {
        let endpoint = APIEndpoints.Projects.search + "?q=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        
        NetworkManager.shared.request(
            endpoint: endpoint,
            method: .get,
            requiresAuth: false,
            completion: completion
        )
    }
    
    // MARK: - Get Categories
    func getAllCategories(completion: @escaping (Result<[ProjectCategory], NetworkError>) -> Void) {
        NetworkManager.shared.request(
            endpoint: APIEndpoints.Categories.list,
            method: .get,
            requiresAuth: false,
            completion: completion
        )
    }
    
    // MARK: - Filter Projects by Category
    func getProjectsByCategory(
        categoryId: Int,
        completion: @escaping (Result<ProjectListResponse, NetworkError>) -> Void
    ) {
        let endpoint = APIEndpoints.Projects.list + "?category_id=\(categoryId)"
        
        NetworkManager.shared.request(
            endpoint: endpoint,
            method: .get,
            requiresAuth: false,
            completion: completion
        )
    }
    
    // MARK: - Create Project (Optional)
    func createProject(
        title: String,
        description: String,
        categoryId: Int,
        completion: @escaping (Result<Project, NetworkError>) -> Void
    ) {
        let parameters: [String: Any] = [
            "title": title,
            "description": description,
            "category_id": categoryId
        ]
        
        NetworkManager.shared.request(
            endpoint: APIEndpoints.Projects.create,
            method: .post,
            parameters: parameters,
            requiresAuth: true,
            completion: completion
        )
    }
    
    // MARK: - Update Project (Optional)
    func updateProject(
        projectId: Int,
        title: String? = nil,
        description: String? = nil,
        categoryId: Int? = nil,
        completion: @escaping (Result<Project, NetworkError>) -> Void
    ) {
        var parameters: [String: Any] = [:]
        
        if let title = title {
            parameters["title"] = title
        }
        if let description = description {
            parameters["description"] = description
        }
        if let categoryId = categoryId {
            parameters["category_id"] = categoryId
        }
        
        let endpoint = APIEndpoints.endpoint(base: APIEndpoints.Projects.update, id: projectId)
        
        NetworkManager.shared.request(
            endpoint: endpoint,
            method: .patch,
            parameters: parameters,
            requiresAuth: true,
            completion: completion
        )
    }
}

// MARK: - Funding Model Service
class FundingModelService {
    
    static let shared = FundingModelService()
    private init() {}
    
    func getFundingModels(completion: @escaping (Result<[FundingModel], NetworkError>) -> Void) {
        NetworkManager.shared.request(
            endpoint: APIEndpoints.FundingModels.list,
            method: .get,
            requiresAuth: false,
            completion: completion
        )
    }
    
    func getFundingModelById(id: Int, completion: @escaping (Result<FundingModel, NetworkError>) -> Void) {
        let endpoint = APIEndpoints.endpoint(base: APIEndpoints.FundingModels.detail, id: id)
        
        NetworkManager.shared.request(
            endpoint: endpoint,
            method: .get,
            requiresAuth: false,
            completion: completion
        )
    }
}

// MARK: - Team Member Service
class TeamMemberService {
    
    static let shared = TeamMemberService()
    private init() {}
    
    func getTeamMembers(projectId: Int, completion: @escaping (Result<[TeamMember], NetworkError>) -> Void) {
        let endpoint = APIEndpoints.TeamMembers.list + "?project_id=\(projectId)"
        
        NetworkManager.shared.request(
            endpoint: endpoint,
            method: .get,
            requiresAuth: false,
            completion: completion
        )
    }
}

// MARK: - Social Links Service
class SocialLinksService {
    
    static let shared = SocialLinksService()
    private init() {}
    
    func getSocialLinks(projectId: Int, completion: @escaping (Result<[SocialLink], NetworkError>) -> Void) {
        let endpoint = APIEndpoints.SocialLinks.list + "?project_id=\(projectId)"
        
        NetworkManager.shared.request(
            endpoint: endpoint,
            method: .get,
            requiresAuth: false,
            completion: completion
        )
    }
}
