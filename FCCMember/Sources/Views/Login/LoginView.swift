import SwiftUI

struct LoginView: View {
    @ObservedObject var sessionManager = SessionManager.shared
    
    @State private var phone: String = ""
    @State private var pin: String = ""
    @State private var isFamily: Bool = false
    @State private var isLoading: Bool = false
    @State private var errorMessage: String? = nil
    @State private var showLegalModal: Bool = false
    
    var onLoginSuccess: (LoginResponse) -> Void
    
    private var isPhoneValid: Bool {
        let trimmed = phone.trimmingCharacters(in: .whitespaces)
        return trimmed.count == 10 && (trimmed.hasPrefix("06") || trimmed.hasPrefix("07"))
    }
    
    var body: some View {
        ZStack {
            // Background
            FCCColors.bgDark.ignoresSafeArea()
            
            // Soft gold gradient top
            LinearGradient(
                colors: [FCCColors.gold.opacity(0.12), Color.clear],
                startPoint: .top,
                endPoint: .center
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    Spacer(minLength: 40)
                    
                    // Logo
                    Image("fcc_logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 130, height: 130)
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                        .shadow(color: FCCColors.gold.opacity(0.3), radius: 15, x: 0, y: 8)
                    
                    VStack(spacing: 6) {
                        Text("Fès Country Club")
                            .font(.system(size: 26, weight: .heavy))
                            .foregroundColor(FCCColors.gold)
                        
                        Text("Espace Membre Officiel")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(FCCColors.textSecondary)
                    }
                    
                    Spacer(minLength: 15)
                    
                    // Input Card
                    VStack(spacing: 16) {
                        // Phone input
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Numéro de téléphone")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(FCCColors.textSecondary)
                            
                            HStack {
                                Image(systemName: "phone.fill")
                                    .foregroundColor(isPhoneValid || phone.isEmpty ? FCCColors.gold : FCCColors.errorRed)
                                    .frame(width: 24)
                                
                                TextField("06 / 07 ...", text: $phone)
                                    .keyboardType(.numberPad)
                                    .foregroundColor(FCCColors.textPrimary)
                                    .onChange(of: phone) { val in
                                        if val.count > 10 { phone = String(val.prefix(10)) }
                                    }
                            }
                            .padding()
                            .background(FCCColors.cardBg)
                            .cornerRadius(14)
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(!isPhoneValid && !phone.isEmpty ? FCCColors.errorRed : FCCColors.cardLight, lineWidth: 1)
                            )
                            
                            if !isPhoneValid && !phone.isEmpty {
                                Text("Doit commencer par 06 ou 07 (10 chiffres)")
                                    .font(.caption2)
                                    .foregroundColor(FCCColors.errorRed)
                            }
                        }
                        
                        // PIN input
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Code d'accès PIN")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(FCCColors.textSecondary)
                            
                            HStack {
                                Image(systemName: "lock.fill")
                                    .foregroundColor(FCCColors.gold)
                                    .frame(width: 24)
                                
                                SecureField("Code reçu par SMS", text: $pin)
                                    .keyboardType(.numberPad)
                                    .foregroundColor(FCCColors.textPrimary)
                            }
                            .padding()
                            .background(FCCColors.cardBg)
                            .cornerRadius(14)
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(FCCColors.cardLight, lineWidth: 1)
                            )
                        }
                        
                        // Family toggle
                        Toggle(isOn: $isFamily) {
                            HStack {
                                Image(systemName: "person.3.fill")
                                    .foregroundColor(isFamily ? FCCColors.gold : FCCColors.textSecondary)
                                Text("Accès Famille (Manager)")
                                    .font(.subheadline)
                                    .foregroundColor(FCCColors.textPrimary)
                            }
                        }
                        .toggleStyle(SwitchToggleStyle(tint: FCCColors.gold))
                        .padding(.vertical, 4)
                        
                        // Error message
                        if let err = errorMessage {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(FCCColors.errorRed)
                                Text(err)
                                    .font(.caption)
                                    .foregroundColor(FCCColors.errorRed)
                            }
                            .padding(.top, 4)
                        }
                        
                        // Submit button
                        Button(action: handleLogin) {
                            HStack {
                                if isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .black))
                                } else {
                                    Text("Se Connecter")
                                        .font(.system(size: 17, weight: .bold))
                                        .foregroundColor(.black)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(isPhoneValid && !pin.isEmpty ? FCCColors.gold : Color.gray.opacity(0.3))
                            .cornerRadius(14)
                            .shadow(color: isPhoneValid && !pin.isEmpty ? FCCColors.gold.opacity(0.3) : .clear, radius: 8, x: 0, y: 4)
                        }
                        .disabled(!isPhoneValid || pin.isEmpty || isLoading)
                    }
                    .padding(20)
                    .background(FCCColors.greenDark.opacity(0.85))
                    .cornerRadius(20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(FCCColors.cardLight, lineWidth: 1)
                    )
                    .padding(.horizontal, 20)
                    
                    // Legal footer
                    Button(action: { showLegalModal = true }) {
                        Text("En vous connectant, vous acceptez les Conditions d'Utilisation (CGU)\net la Politique de Confidentialité CNDP")
                            .font(.caption2)
                            .foregroundColor(FCCColors.textSecondary.opacity(0.7))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 30)
                    }
                    .sheet(isPresented: $showLegalModal) {
                        LegalComplianceView()
                    }
                    
                    Spacer(minLength: 30)
                }
            }
        }
        .onAppear {
            let saved = sessionManager.getSavedPhone()
            if !saved.isEmpty { self.phone = saved }
        }
    }
    
    private func handleLogin() {
        guard isPhoneValid && !pin.isEmpty else { return }
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let userType = isFamily ? "family" : "individual"
                let response = try await MemberAPIService.shared.login(phone: phone, pin: pin, type: userType)
                await MainActor.run {
                    self.isLoading = false
                    if let token = response.token {
                        sessionManager.savePhone(phone)
                        sessionManager.saveSession(token: token, userType: userType)
                    }
                    onLoginSuccess(response)
                }
            } catch {
                await MainActor.run {
                    self.isLoading = false
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
}
