import Foundation

// MARK: - Login & Profile Responses
struct LoginResponse: Codable {
    let token: String?
    let type: String
    let data: UserData
}

struct UserData: Codable {
    let id: Int
    let name: String
    let membership_id: String?
    let family_code: String?
    let photo: String?
    let qr_token: String?
    let status: String?
    let status_reason: String?
    let members: [FamilyMemberItem]?
    let subscription: SubscriptionData?
    let payments: [PaymentData]?
    let access_history: [AccessLogData]?
    let wallet: WalletData?
}

struct FamilyMemberItem: Codable, Identifiable {
    let id: Int
    let name: String
    let photo: String?
    let relationship: String?
}

struct SubscriptionData: Codable {
    let type: String
    let end_date: String
    let status: String
    let price: String
}

struct PaymentData: Codable, Identifiable {
    let id: Int
    let number: String
    let amount: String
    let date: String
    let method: String
    let status: String
}

struct AccessLogData: Codable, Identifiable {
    let id: Int
    let time: String?
    let facility: String
    let status: String
    let member_name: String?
}

struct QRResponse: Codable {
    let token: String
    let qr_image_url: String?
    let expires_at: String?
}

// MARK: - Notifications
struct NotificationsResponse: Codable {
    let success: Bool
    let notifications: [NotificationData]
    let unread_count: Int
}

struct NotificationData: Codable, Identifiable {
    let id: Int64
    let title: String
    let body: String
    let type: String
    let read: Bool
    let created_at: String
}

// MARK: - Wallet RTCF & Kiosk Models
struct WalletData: Codable {
    let id: Int?
    let balance: Double?
    let cashback_balance: Double?
    let total_balance: Double?
    let rfid_card_number: String?
    let status: String?
    let has_active_card: Bool?
    let used_in_last_7_days: Bool?
    let can_generate_kiosk_code: Bool?
    let cards: [WalletCardData]?
    let transactions: [WalletTransactionData]?
    
    var safeBalance: Double { balance ?? 0.0 }
    var safeTotalBalance: Double { total_balance ?? (balance ?? 0.0) }
    var safeCashback: Double { cashback_balance ?? 0.0 }
}

struct WalletCardData: Codable, Identifiable {
    let id: Int
    let rfid_card_number: String
    let holder_name: String?
    let is_active: Bool?
    let spending_limit: Double?
    let spending_limit_type: String?
}

struct WalletTransactionData: Codable, Identifiable {
    let id: Int
    let type: String // debit, credit, cashback
    let amount: Double
    let description: String?
    let date: String
}

struct KioskPaymentCodeResponse: Codable {
    let success: Bool
    let code: String?
    let formatted_code: String?
    let expires_at: String?
    let validity_minutes: Int?
    let validity_seconds: Int?
    let message: String?
}

struct KioskCodeStatusResponse: Codable {
    let success: Bool
    let has_active_code: Bool?
    let code: String?
    let formatted_code: String?
    let expires_at: String?
    let remaining_seconds: Int64?
}
