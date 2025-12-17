import Foundation

enum NetworkError: Error {
    case invalidURL
    case noData
    case decodingError
    case server(String)
    case unauthorized
    case other(Error)
}

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
}

final class NetworkManager {
    static let shared = NetworkManager()
<<<<<<< HEAD
    
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
=======
    private init() {}

    private let session = URLSession(configuration: .default)

    func request<T: Decodable>(
>>>>>>> cb2003e (init)
        endpoint: String,
        method: HTTPMethod,
        parameters: [String: Any]? = nil,
        requiresAuth: Bool = false,
        completion: @escaping (Result<T, NetworkError>) -> Void
    ) {
        let urlString = APIEndpoints.baseURL + endpoint
        guard let url = URL(string: urlString) else {
            completion(.failure(.invalidURL))
            return
        }

        var req = URLRequest(url: url)
        req.httpMethod = method.rawValue
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if requiresAuth {
            guard let token = AuthManager.shared.getAccessToken() else {
                completion(.failure(.unauthorized))
                return
            }
            req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        if let parameters = parameters {
            do {
                req.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
            } catch {
                completion(.failure(.other(error)))
                return
            }
        }

        session.dataTask(with: req) { data, response, error in
            if let error = error {
                DispatchQueue.main.async { completion(.failure(.other(error))) }
                return
            }

            guard let http = response as? HTTPURLResponse else {
                DispatchQueue.main.async { completion(.failure(.noData)) }
                return
            }

            let status = http.statusCode

            // 401
            if status == 401 {
                DispatchQueue.main.async { completion(.failure(.unauthorized)) }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async { completion(.failure(.noData)) }
                return
            }

            // 200-299
            if (200...299).contains(status) {
                do {
                    let decoded = try JSONDecoder().decode(T.self, from: data)
                    DispatchQueue.main.async { completion(.success(decoded)) }
                } catch {
                    DispatchQueue.main.async { completion(.failure(.decodingError)) }
                }
                return
            }

            // ошибки
            if let apiErr = try? JSONDecoder().decode(APIErrorResponse.self, from: data) {
                DispatchQueue.main.async { completion(.failure(.server(apiErr.detail ?? "Server error"))) }
            } else {
                DispatchQueue.main.async { completion(.failure(.server("HTTP \(status)"))) }
            }
        }.resume()
    }

    /// Для запросов где тело ответа не нужно
    func requestVoid(
        endpoint: String,
        method: HTTPMethod,
        parameters: [String: Any]? = nil,
        requiresAuth: Bool = false,
        completion: @escaping (Result<Void, NetworkError>) -> Void
    ) {
        request(endpoint: endpoint, method: method, parameters: parameters, requiresAuth: requiresAuth) { (result: Result<EmptyDecodable, NetworkError>) in
            switch result {
            case .success: completion(.success(()))
            case .failure(let e): completion(.failure(e))
            }
        }
    }
}

private struct EmptyDecodable: Decodable {}
