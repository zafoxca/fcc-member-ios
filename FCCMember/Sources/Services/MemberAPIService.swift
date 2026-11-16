import Foundation

enum APIError: LocalizedError {
    case invalidURL
    case serverError(String)
    case unauthorized
    case decodingError(String)
    case networkError(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "URL invalide"
        case .serverError(let msg):
            return msg
        case .unauthorized:
            return "Session expirée ou code d'accès incorrect."
        case .decodingError(let msg):
            return "Format de données invalide : \(msg)"
        case .networkError(let msg):
            return "Erreur de connexion : \(msg)"
        }
    }
}

class MemberAPIService {
    static let shared = MemberAPIService()
    private let baseURL = "https://erp.fescountry.club/api/"
    
    private init() {}
    
    // MARK: - Login
    func login(phone: String, pin: String, type: String) async throws -> LoginResponse {
        guard let url = URL(string: baseURL + "member/login") else { throw APIError.invalidURL }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let body: [String: String] = [
            "phone": phone,
            "pin": pin,
            "type": type
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.serverError("Réponse serveur invalide.")
        }
        
        if httpResponse.statusCode == 401 || httpResponse.statusCode == 403 {
            throw APIError.unauthorized
        }
        
        if !(200...299).contains(httpResponse.statusCode) {
            let errorMsg = parseErrorMessage(data) ?? "Erreur de connexion (\(httpResponse.statusCode))"
            throw APIError.serverError(errorMsg)
        }
        
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(LoginResponse.self, from: data)
        } catch {
            throw APIError.decodingError(error.localizedDescription)
        }
    }
    
    // MARK: - Profile
    func getProfile(token: String) async throws -> LoginResponse {
        guard let url = URL(string: baseURL + "member/profile") else { throw APIError.invalidURL }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.serverError("Réponse serveur invalide.")
        }
        
        if httpResponse.statusCode == 401 { throw APIError.unauthorized }
        
        let decoder = JSONDecoder()
        return try decoder.decode(LoginResponse.self, from: data)
    }
    
    // MARK: - Dynamic Access QR
    func getAccessQR(token: String) async throws -> QRResponse {
        guard let url = URL(string: baseURL + "member/qr") else { throw APIError.invalidURL }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let decoder = JSONDecoder()
        return try decoder.decode(QRResponse.self, from: data)
    }
    
    // MARK: - Upload Mandatory Profile Photo
    func uploadPhoto(token: String, base64Photo: String) async throws {
        guard let url = URL(string: baseURL + "member/photo") else { throw APIError.invalidURL }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = ["photo": base64Photo]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (_, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw APIError.serverError("Échec de l'enregistrement de la photo.")
        }
    }
    
    // MARK: - Notifications
    func getNotifications(token: String) async throws -> NotificationsResponse {
        guard let url = URL(string: baseURL + "member/notifications") else { throw APIError.invalidURL }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let decoder = JSONDecoder()
        return try decoder.decode(NotificationsResponse.self, from: data)
    }
    
    func markNotificationRead(token: String, id: Int64) async throws {
        guard let url = URL(string: baseURL + "member/notifications/\(id)/read") else { throw APIError.invalidURL }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        _ = try await URLSession.shared.data(for: request)
    }
    
    func markAllNotificationsRead(token: String) async throws {
        guard let url = URL(string: baseURL + "member/notifications/read-all") else { throw APIError.invalidURL }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        _ = try await URLSession.shared.data(for: request)
    }
    
    // MARK: - Kiosk Payment Code
    func generateKioskCode(token: String) async throws -> KioskPaymentCodeResponse {
        guard let url = URL(string: baseURL + "member/kiosk/generate-code") else { throw APIError.invalidURL }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let decoder = JSONDecoder()
        return try decoder.decode(KioskPaymentCodeResponse.self, from: data)
    }
    
    func getKioskCodeStatus(token: String) async throws -> KioskCodeStatusResponse {
        guard let url = URL(string: baseURL + "member/kiosk/code-status") else { throw APIError.invalidURL }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let decoder = JSONDecoder()
        return try decoder.decode(KioskCodeStatusResponse.self, from: data)
    }
    
    private func parseErrorMessage(_ data: Data) -> String? {
        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            if let msg = json["message"] as? String { return msg }
            if let err = json["error"] as? String { return err }
        }
        return nil
    }
}
