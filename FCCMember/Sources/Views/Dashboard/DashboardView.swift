import SwiftUI

struct DashboardView: View {
    @ObservedObject var sessionManager = SessionManager.shared
    
    @State private var userData: UserData?
    @State private var notifications: [NotificationData] = []
    @State private var qrToken: String?
    @State private var isLoading: Bool = true
    @State private var errorMessage: String?
    
    @State private var showQRModal: Bool = false
    @State private var showNotifSheet: Bool = false
    @State private var showLegalModal: Bool = false
    @State private var showKioskCodeDialog: Bool = false
    @State private var kioskCodeResponse: KioskPaymentCodeResponse?
    @State private var kioskLoading: Bool = false
    
    var onRequirePhoto: () -> Void
    var onLogout: () -> Void
    
    var unreadCount: Int {
        notifications.filter { !$0.read }.count
    }
    
    var body: some View {
        ZStack {
            FCCColors.bgDark.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top Custom App Bar
                HStack(spacing: 12) {
                    Image("fcc_logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 38, height: 38)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Fès Country Club")
                            .font(.system(size: 16, weight: .heavy))
                            .foregroundColor(FCCColors.gold)
                        Text("Espace Membre Privilège")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(FCCColors.textSecondary)
                    }
                    
                    Spacer()
                    
                    // Legal button
                    Button(action: { showLegalModal = true }) {
                        Image(systemName: "doc.text.fill")
                            .foregroundColor(FCCColors.gold)
                            .frame(width: 32, height: 32)
                    }
                    
                    // Notifications button with badge
                    Button(action: { showNotifSheet = true }) {
                        ZStack(alignment: .topTrailing) {
                            Image(systemName: "bell.fill")
                                .foregroundColor(FCCColors.gold)
                                .frame(width: 32, height: 32)
                            
                            if unreadCount > 0 {
                                Text("\(unreadCount)")
                                    .font(.system(size: 9, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(4)
                                    .background(FCCColors.errorRed)
                                    .clipShape(Circle())
                                    .offset(x: 4, y: -4)
                            }
                        }
                    }
                    
                    // Logout button
                    Button(action: logout) {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .foregroundColor(FCCColors.errorRed)
                            .frame(width: 32, height: 32)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(FCCColors.green)
                
                // Content ScrollView
                if isLoading && userData == nil {
                    VStack {
                        Spacer()
                        ProgressView("Chargement de votre espace...")
                            .progressViewStyle(CircularProgressViewStyle(tint: FCCColors.gold))
                            .foregroundColor(FCCColors.textSecondary)
                        Spacer()
                    }
                } else if let user = userData {
                    ScrollView {
                        VStack(spacing: 20) {
                            // Member Header Card
                            memberHeaderCard(user)
                            
                            // Turnstile Access QR Code Card
                            accessQRCodeCard(user)
                            
                            // Wallet Section
                            WalletSectionView(
                                wallet: user.wallet,
                                isFamily: sessionManager.userType == "family",
                                onGenerateKioskCode: generateKioskCode
                            )
                            
                            // Subscription Info Card
                            if let sub = user.subscription {
                                subscriptionCard(sub)
                            }
                            
                            // Family Members (if any)
                            if let members = user.members, !members.isEmpty {
                                familyMembersCard(members)
                            }
                            
                            Spacer(minLength: 40)
                        }
                        .padding(.top, 16)
                    }
                    .refreshable {
                        await loadDashboardData()
                    }
                } else if let err = errorMessage {
                    VStack(spacing: 16) {
                        Spacer()
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.largeTitle)
                            .foregroundColor(FCCColors.errorRed)
                        Text(err)
                            .font(.subheadline)
                            .foregroundColor(FCCColors.textPrimary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        Button("Réessayer") {
                            Task { await loadDashboardData() }
                        }
                        .padding(.horizontal, 24)
                        .padding(.vertical, 10)
                        .background(FCCColors.gold)
                        .foregroundColor(.black)
                        .cornerRadius(10)
                        Spacer()
                    }
                }
            }
            
            // Kiosk Code Dialog Overlay
            if showKioskCodeDialog, let res = kioskCodeResponse, let code = res.code {
                KioskCodeDialogView(
                    code: code,
                    formattedCode: res.formatted_code ?? code,
                    expiresAt: res.expires_at,
                    remainingSeconds: Int64(res.validity_seconds ?? 900),
                    onDismiss: { showKioskCodeDialog = false }
                )
            }
        }
        .sheet(isPresented: $showQRModal) {
            if let token = qrToken ?? userData?.qr_token {
                QRCodeFullscreenView(token: token, memberName: userData?.name ?? "Adhérent")
            }
        }
        .sheet(isPresented: $showNotifSheet) {
            if let tok = sessionManager.token {
                NotificationsSheetView(notifications: $notifications, token: tok)
            }
        }
        .sheet(isPresented: $showLegalModal) {
            LegalComplianceView()
        }
        .onAppear {
            Task { await loadDashboardData() }
        }
    }
    
    // MARK: - Subviews
    private func memberHeaderCard(_ user: UserData) -> some View {
        HStack(spacing: 16) {
            // Photo / Avatar
            ZStack {
                if let photoUrl = user.photo, let url = URL(string: photoUrl.hasPrefix("http") ? photoUrl : "https://erp.fescountry.club/storage/" + photoUrl) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image.resizable().scaledToFill()
                        default:
                            Image(systemName: "person.fill").foregroundColor(FCCColors.gold)
                        }
                    }
                    .frame(width: 64, height: 64)
                    .clipShape(Circle())
                } else {
                    Circle()
                        .fill(FCCColors.cardLight)
                        .frame(width: 64, height: 64)
                        .overlay(
                            Image(systemName: "person.fill")
                                .font(.title)
                                .foregroundColor(FCCColors.gold)
                        )
                }
            }
            .overlay(Circle().stroke(FCCColors.gold, lineWidth: 2))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(user.name)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(FCCColors.textPrimary)
                
                HStack(spacing: 8) {
                    if let num = user.membership_id ?? user.family_code {
                        Text("#\(num)")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(FCCColors.gold)
                    }
                    
                    Text("MEMBRE ACTIF")
                        .font(.system(size: 9, weight: .heavy))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(FCCColors.successGreen.opacity(0.2))
                        .foregroundColor(FCCColors.successGreen)
                        .cornerRadius(6)
                }
            }
            
            Spacer()
        }
        .padding(18)
        .background(FCCColors.cardBg)
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(FCCColors.cardLight, lineWidth: 1)
        )
        .padding(.horizontal, 20)
    }
    
    private func accessQRCodeCard(_ user: UserData) -> some View {
        VStack(spacing: 14) {
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "qrcode")
                        .foregroundColor(FCCColors.gold)
                    Text("BADGE D'ACCÈS TOURNIQUET")
                        .font(.system(size: 13, weight: .heavy))
                        .foregroundColor(FCCColors.gold)
                        .tracking(1)
                }
                Spacer()
            }
            
            Button(action: { showQRModal = true }) {
                HStack(spacing: 14) {
                    if let token = qrToken ?? user.qr_token, let qr = QRCodeHelper.generateQRCode(from: token, size: 70) {
                        Image(uiImage: qr)
                            .interpolation(.none)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 54, height: 54)
                            .padding(4)
                            .background(Color.white)
                            .cornerRadius(8)
                    }
                    
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Afficher mon QR Code")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(FCCColors.textPrimary)
                        Text("Valable pour les barrières et tourniquets")
                            .font(.caption2)
                            .foregroundColor(FCCColors.textSecondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "arrow.up.left.and.arrow.down.right")
                        .foregroundColor(FCCColors.gold)
                }
                .padding(14)
                .background(FCCColors.greenDark)
                .cornerRadius(14)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(FCCColors.gold.opacity(0.4), lineWidth: 1)
                )
            }
        }
        .padding(18)
        .background(FCCColors.cardBg)
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(FCCColors.cardLight, lineWidth: 1)
        )
        .padding(.horizontal, 20)
    }
    
    private func subscriptionCard(_ sub: SubscriptionData) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("ABONNEMENT")
                    .font(.system(size: 12, weight: .heavy))
                    .foregroundColor(FCCColors.gold)
                Spacer()
                Text(sub.status.uppercased())
                    .font(.system(size: 10, weight: .bold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(FCCColors.successGreen.opacity(0.2))
                    .foregroundColor(FCCColors.successGreen)
                    .cornerRadius(6)
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(sub.type)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(FCCColors.textPrimary)
                    Text("Valide jusqu'au \(sub.end_date)")
                        .font(.caption)
                        .foregroundColor(FCCColors.textSecondary)
                }
                Spacer()
                Text(sub.price)
                    .font(.headline)
                    .fontWeight(.heavy)
                    .foregroundColor(FCCColors.gold)
            }
        }
        .padding(18)
        .background(FCCColors.cardBg)
        .cornerRadius(20)
        .padding(.horizontal, 20)
    }
    
    private func familyMembersCard(_ members: [FamilyMemberItem]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("MEMBRES DE LA FAMILLE")
                .font(.system(size: 12, weight: .heavy))
                .foregroundColor(FCCColors.gold)
            
            ForEach(members) { m in
                HStack(spacing: 12) {
                    Circle()
                        .fill(FCCColors.cardLight)
                        .frame(width: 36, height: 36)
                        .overlay(Image(systemName: "person.fill").foregroundColor(FCCColors.gold))
                    VStack(alignment: .leading, spacing: 2) {
                        Text(m.name)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(FCCColors.textPrimary)
                        Text(m.relationship ?? "Membre")
                            .font(.caption2)
                            .foregroundColor(FCCColors.textSecondary)
                    }
                    Spacer()
                }
                .padding(.vertical, 4)
            }
        }
        .padding(18)
        .background(FCCColors.cardBg)
        .cornerRadius(20)
        .padding(.horizontal, 20)
    }
    
    // MARK: - Logic
    private func loadDashboardData() async {
        guard let token = sessionManager.token else {
            logout()
            return
        }
        
        do {
            let res = try await MemberAPIService.shared.getProfile(token: token)
            let notifRes = try? await MemberAPIService.shared.getNotifications(token: token)
            let qrRes = try? await MemberAPIService.shared.getAccessQR(token: token)
            
            await MainActor.run {
                self.userData = res.data
                self.notifications = notifRes?.notifications ?? []
                self.qrToken = qrRes?.token ?? res.data.qr_token
                self.isLoading = false
                
                // If photo is mandatory and missing, trigger photo flow
                if res.data.photo == nil || res.data.photo?.isEmpty == true {
                    onRequirePhoto()
                }
            }
        } catch {
            await MainActor.run {
                self.isLoading = false
                self.errorMessage = error.localizedDescription
            }
        }
    }
    
    private func generateKioskCode() {
        guard let token = sessionManager.token else { return }
        kioskLoading = true
        Task {
            do {
                let res = try await MemberAPIService.shared.generateKioskCode(token: token)
                await MainActor.run {
                    kioskLoading = false
                    kioskCodeResponse = res
                    showKioskCodeDialog = true
                }
            } catch {
                await MainActor.run {
                    kioskLoading = false
                }
            }
        }
    }
    
    private func logout() {
        sessionManager.clearSession()
        onLogout()
    }
}

// Fullscreen Access QR
struct QRCodeFullscreenView: View {
    let token: String
    let memberName: String
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            FCCColors.bgDark.ignoresSafeArea()
            
            VStack(spacing: 24) {
                HStack {
                    Spacer()
                    Button("Fermer") { dismiss() }
                        .foregroundColor(FCCColors.gold)
                        .fontWeight(.bold)
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                
                Spacer()
                
                VStack(spacing: 16) {
                    Text("Badge d'Accès Tourniquet")
                        .font(.title2)
                        .fontWeight(.heavy)
                        .foregroundColor(FCCColors.gold)
                    
                    Text(memberName)
                        .font(.headline)
                        .foregroundColor(FCCColors.textPrimary)
                    
                    if let qr = QRCodeHelper.generateQRCode(from: token, size: 280) {
                        Image(uiImage: qr)
                            .interpolation(.none)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 250, height: 250)
                            .padding(20)
                            .background(Color.white)
                            .cornerRadius(20)
                            .shadow(color: FCCColors.gold.opacity(0.3), radius: 15)
                    }
                    
                    Text("Présentez ce QR Code face au lecteur optique de la borne ou du tourniquet.")
                        .font(.caption)
                        .foregroundColor(FCCColors.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)
                }
                
                Spacer()
            }
        }
    }
}
