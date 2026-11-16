import Foundation
import Combine

class SessionManager: ObservableObject {
    static let shared = SessionManager()
    
    private let tokenKey = "fcc_auth_token"
    private let phoneKey = "fcc_saved_phone"
    private let userTypeKey = "fcc_user_type"
    
    @Published var token: String?
    @Published var isLoggedIn: Bool = false
    @Published var userType: String = "individual" // "individual" or "family"
    
    private init() {
        if let savedToken = UserDefaults.standard.string(forKey: tokenKey), !savedToken.isEmpty {
            self.token = savedToken
            self.isLoggedIn = true
        }
        self.userType = UserDefaults.standard.string(forKey: userTypeKey) ?? "individual"
    }
    
    func saveSession(token: String, userType: String) {
        self.token = token
        self.userType = userType
        self.isLoggedIn = true
        UserDefaults.standard.set(token, forKey: tokenKey)
        UserDefaults.standard.set(userType, forKey: userTypeKey)
    }
    
    func savePhone(_ phone: String) {
        UserDefaults.standard.set(phone, forKey: phoneKey)
    }
    
    func getSavedPhone() -> String {
        return UserDefaults.standard.string(forKey: phoneKey) ?? ""
    }
    
    func clearSession() {
        self.token = nil
        self.isLoggedIn = false
        UserDefaults.standard.removeObject(forKey: tokenKey)
        UserDefaults.standard.removeObject(forKey: userTypeKey)
    }
}
