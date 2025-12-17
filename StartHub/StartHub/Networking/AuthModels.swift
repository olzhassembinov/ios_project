import Foundation

// SimpleJWT: /api/token/ -> { "refresh": "...", "access": "..." }
struct TokenPair: Decodable {
    let refresh: String
    let access: String
}

// /api/token/refresh/ -> { "access": "..." }
struct AccessTokenResponse: Decodable {
    let access: String
}

// Register endpoint может вернуть разные поля — делаем безопасно
struct RegisterResponse: Decodable {
    let id: Int?
    let username: String?
    let email: String?
}

// /api/auth/me/
struct MeResponse: Decodable {
    let id: Int?
    let username: String?
    let email: String?
}

// DRF-ошибки часто: { "detail": "...", "code": "..." }
struct APIErrorResponse: Decodable {
    let detail: String?
    let code: String?
}
