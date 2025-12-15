//
//  Models.swift
//  StartHub
//
//  Created by Олжас Сембинов on 15.12.2025.
//

//
//  Models.swift
//  StartHub
//
//  Data models matching Django database schema
//

import Foundation

// MARK: - User Model (PERSON 1)
struct User: Codable {
    let id: Int
    let email: String
    let name: String?
    let surname: String?
    let firstName: String?
    let lastName: String?
    let picture: String?
    let isSuperuser: Bool?
    let isStaff: Bool?
    let dateJoined: String?
    let lastLogin: String?
    
    // Related fields
    let roles: [Role]?
    let company: Company?
    
    enum CodingKeys: String, CodingKey {
        case id
        case email
        case name
        case surname
        case firstName = "first_name"
        case lastName = "last_name"
        case picture
        case isSuperuser = "is_superuser"
        case isStaff = "is_staff"
        case dateJoined = "date_joined"
        case lastLogin = "last_login"
        case roles
        case company
    }
}

// MARK: - Role Model
struct Role: Codable {
    let id: Int
    let name: String
}

// MARK: - Company Model
struct Company: Codable {
    let id: Int
    let name: String
    let description: String?
    let companyId: String?
    let establishedDate: String?
    let country: Country?
    let slug: String?
    let businessId: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case companyId = "company_id"
        case establishedDate = "established_date"
        case country
        case slug
        case businessId = "business_id"
    }
}

// MARK: - Country Model
struct Country: Codable {
    let id: Int
    let code: String
    let name: String?
}

// MARK: - Project Model (PERSON 2)
struct Project: Codable {
    let id: Int
    let title: String
    let description: String?
    let deadline: String?
    let creator: User?
    let creatorId: Int?
    let fundingModel: FundingModel?
    let fundingModelId: Int?
    let category: ProjectCategory?
    let categoryId: Int?
    let slug: String?
    let stage: String?
    let currentSum: Double?
    let plan: String?
    
    // Related data
    let images: [ProjectImage]?
    let teamMembers: [TeamMember]?
    let socialLinks: [SocialLink]?
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case deadline
        case creator
        case creatorId = "creator_id"
        case fundingModel = "funding_model"
        case fundingModelId = "funding_model_id"
        case category
        case categoryId = "category_id"
        case slug
        case stage
        case currentSum = "current_sum"
        case plan
        case images
        case teamMembers = "team_members"
        case socialLinks = "social_links"
    }
}

// MARK: - Project List Response (PERSON 2)
struct ProjectListResponse: Codable {
    let count: Int?
    let next: String?
    let previous: String?
    let results: [Project]
}

// MARK: - Project Category (PERSON 2)
struct ProjectCategory: Codable {
    let id: Int
    let name: String
    let slug: String?
}

// MARK: - Funding Model (PERSON 2)
struct FundingModel: Codable {
    let id: Int
    let name: String
    let slug: String?
    let description: String?
}

// MARK: - Project Image (PERSON 2)
struct ProjectImage: Codable {
    let id: Int
    let projectId: Int
    let filePath: String
    let order: Int?
    
    enum CodingKeys: String, CodingKey {
        case id
        case projectId = "project_id"
        case filePath = "file_path"
        case order
    }
}

// MARK: - Team Member (PERSON 2)
struct TeamMember: Codable {
    let id: Int
    let projectId: Int
    let name: String
    let surname: String?
    let role: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case projectId = "project_id"
        case name
        case surname
        case role
    }
}

// MARK: - Social Link (PERSON 2)
struct SocialLink: Codable {
    let id: Int
    let projectId: Int
    let platform: String
    let url: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case projectId = "project_id"
        case platform
        case url
    }
}

// MARK: - Project Stage (Optional)
struct ProjectStage: Codable {
    let id: Int
    let projectId: Int
    let description: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case projectId = "project_id"
        case description
    }
}
