//
//  NetworkManager.swift
//  StartHub
//
//  Created by Олжас Сембинов on 15.12.2025.
//

//
//  NetworkManager.swift
//  StartHub
//
//  This is the core networking layer that handles all API requests
//

import Foundation
import UIKit

// MARK: - Network Error Types
enum NetworkError: Error {
    case invalidURL
    case noData
    case decodingError(Error)
    case encodingError
    case serverError(String, String?) // message, code
    case unauthorized
    case notFound
    case badRequest(String)
    case unknown(Error)
    
    var localizedDescription: String {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .noData:
            return "No data received from server"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .encodingError:
            return "Failed to encode request"
        case .serverError(let message, let code):
            return code != nil ? "\(message) (Code: \(code!))" : message
        case .unauthorized:
            return "Unauthorized. Please login again."
        case .notFound:
            return "Resource not found"
        case .badRequest(let message):
            return message
        case .unknown(let error):
            return "Unknown error: \(error.localizedDescription)"
        }
    }
}

// MARK: - HTTP Method
enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}

// MARK: - API Response Wrapper
struct APIResponse<T: Codable>: Codable {
    let code: String?
    let detail: String?
    let data: T?
    
    // For error responses
    var errorCode: String? { code }
    var errorMessage: String? { detail }
}

// MARK: - Network Manager
class NetworkManager {
    
    // MARK: - Singleton
    static let shared = NetworkManager()
    
    // MARK: - Properties
    private let baseURL = "46.149.69.209" // TODO: Replace with your actual base URL
    private let session: URLSession
    
    private init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 30
        self.session = URLSession(configuration: configuration)
    }
    
    // MARK: - Generic Request Method
    /// Generic method to make any API request
    /// - Parameters:
    ///   - endpoint: API endpoint (e.g., "/auth/login/")
    ///   - method: HTTP method (GET, POST, etc.)
    ///   - parameters: Request body parameters (optional)
    ///   - headers: Additional headers (optional)
    ///   - requiresAuth: Whether this request requires authentication token
    ///   - completion: Completion handler with Result type
    func request<T: Codable>(
        endpoint: String,
        method: HTTPMethod,
        parameters: [String: Any]? = nil,
        headers: [String: String]? = nil,
        requiresAuth: Bool = false,
        completion: @escaping (Result<T, NetworkError>) -> Void
    ) {
        // Construct URL
        guard let url = URL(string: baseURL + endpoint) else {
            completion(.failure(.invalidURL))
            return
        }
        
        // Create request
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Add custom headers
        headers?.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        // Add authorization header if required
        if requiresAuth {
            if let token = AuthManager.shared.getAccessToken() {
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            } else {
                completion(.failure(.unauthorized))
                return
            }
        }
        
        // Add body parameters
        if let parameters = parameters {
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
            } catch {
                completion(.failure(.encodingError))
                return
            }
        }
        
        // Make request
        let task = session.dataTask(with: request) { data, response, error in
            // Handle network error
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(.unknown(error)))
                }
                return
            }
            
            // Handle HTTP response
            guard let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async {
                    completion(.failure(.noData))
                }
                return
            }
            
            // Handle different status codes
            switch httpResponse.statusCode {
            case 200...299:
                // Success
                guard let data = data else {
                    DispatchQueue.main.async {
                        completion(.failure(.noData))
                    }
                    return
                }
                
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let decodedData = try decoder.decode(T.self, from: data)
                    DispatchQueue.main.async {
                        completion(.success(decodedData))
                    }
                } catch {
                    print("Decoding error: \(error)")
                    if let jsonString = String(data: data, encoding: .utf8) {
                        print("Response JSON: \(jsonString)")
                    }
                    DispatchQueue.main.async {
                        completion(.failure(.decodingError(error)))
                    }
                }
                
            case 401:
                // Unauthorized - token might be expired
                AuthManager.shared.clearTokens()
                DispatchQueue.main.async {
                    completion(.failure(.unauthorized))
                }
                
            case 400:
                // Bad Request
                if let data = data,
                   let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                    DispatchQueue.main.async {
                        completion(.failure(.badRequest(errorResponse.detail ?? "Bad request")))
                    }
                } else {
                    DispatchQueue.main.async {
                        completion(.failure(.badRequest("Invalid request")))
                    }
                }
                
            case 404:
                // Not Found
                DispatchQueue.main.async {
                    completion(.failure(.notFound))
                }
                
            default:
                // Server Error
                if let data = data,
                   let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                    DispatchQueue.main.async {
                        completion(.failure(.serverError(
                            errorResponse.detail ?? "Server error",
                            errorResponse.code
                        )))
                    }
                } else {
                    DispatchQueue.main.async {
                        completion(.failure(.serverError("Server error", nil)))
                    }
                }
            }
        }
        
        task.resume()
    }
    
    // MARK: - Upload Image
    /// Upload image to server
    func uploadImage(
        endpoint: String,
        image: UIImage,
        paramName: String = "image",
        parameters: [String: String]? = nil,
        requiresAuth: Bool = true,
        completion: @escaping (Result<Data, NetworkError>) -> Void
    ) {
        guard let url = URL(string: baseURL + endpoint) else {
            completion(.failure(.invalidURL))
            return
        }
        
        guard let imageData = image.jpegData(compressionQuality: 0.7) else {
            completion(.failure(.encodingError))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        if requiresAuth, let token = AuthManager.shared.getAccessToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        var body = Data()
        
        // Add parameters
        if let parameters = parameters {
            for (key, value) in parameters {
                body.append("--\(boundary)\r\n".data(using: .utf8)!)
                body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
                body.append("\(value)\r\n".data(using: .utf8)!)
            }
        }
        
        // Add image
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"\(paramName)\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(.unknown(error)))
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode),
                  let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(.serverError("Upload failed", nil)))
                }
                return
            }
            
            DispatchQueue.main.async {
                completion(.success(data))
            }
        }
        
        task.resume()
    }
}

// MARK: - Error Response Model
struct ErrorResponse: Codable {
    let detail: String?
    let code: String?
}
