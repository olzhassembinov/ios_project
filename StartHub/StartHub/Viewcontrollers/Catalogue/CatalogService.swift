//
//  CatalogService.swift
//  StartHub
//
//  Created by Adlet Trum on 16.12.2025.
//

import Foundation

final class CatalogService {

    func fetchProjects(completion: @escaping (Result<[Project], NetworkError>) -> Void) {

        NetworkManager.shared.request(
            endpoint: APIEndpoints.Projects.list,
            method: .get,
            requiresAuth: false
        ) { (result: Result<ProjectListResponse, NetworkError>) in

            switch result {
            case .success(let response):
                completion(.success(response.results))

            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
