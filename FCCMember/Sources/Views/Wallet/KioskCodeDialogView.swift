import SwiftUI

struct KioskCodeDialogView: View {
    let code: String
    let formattedCode: String
    let expiresAt: String?
    let remainingSeconds: Int64
    var onDismiss: () -> Void
    
    @State private var countdown: Int64 = 0
    @State private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.75).ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("CODE PAIEMENT KIOSQUE")
                            .font(.system(size: 13, weight: .heavy))
                            .foregroundColor(FCCColors.gold)
                        Text("À saisir sur la borne de commande")
                            .font(.caption2)
                            .foregroundColor(FCCColors.textSecondary)
                    }
                    Spacer()
                    Button(action: onDismiss) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.gray)
                    }
                }
                
                // Big formatted code
                VStack(spacing: 6) {
                    Text(formattedCode.isEmpty ? code : formattedCode)
                        .font(.system(size: 38, weight: .heavy, design: .monospaced))
                        .foregroundColor(FCCColors.gold)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 24)
                        .background(FCCColors.bgDark)
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(FCCColors.gold.opacity(0.4), lineWidth: 2)
                        )
                }
                
                // Countdown timer
                HStack(spacing: 6) {
                    Image(systemName: "clock.fill")
                        .font(.caption)
                    Text("Expire dans \(formattedTime(countdown))")
                        .font(.caption)
                        .fontWeight(.bold)
                }
                .foregroundColor(countdown < 120 ? FCCColors.errorRed : FCCColors.gold)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.black.opacity(0.4))
                .cornerRadius(20)
                
                // QR code representation for optical scan
                if let qrImg = QRCodeHelper.generateQRCode(from: "FCC-KIOSK:" + code, size: 160) {
                    Image(uiImage: qrImg)
                        .interpolation(.none)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 140, height: 140)
                        .padding(10)
                        .background(Color.white)
                        .cornerRadius(14)
                }
                
                Text("Usage unique • Débit direct sur votre solde Wallet")
                    .font(.system(size: 11))
                    .foregroundColor(FCCColors.textSecondary)
                
                Button(action: onDismiss) {
                    Text("J'ai terminé")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(FCCColors.gold)
                        .foregroundColor(.black)
                        .cornerRadius(12)
                }
            }
            .padding(22)
            .background(FCCColors.greenDark)
            .cornerRadius(24)
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(FCCColors.cardLight, lineWidth: 1)
            )
            .padding(24)
        }
        .onAppear {
            self.countdown = remainingSeconds > 0 ? remainingSeconds : 900
        }
        .onReceive(timer) { _ in
            if countdown > 0 {
                countdown -= 1
            } else {
                onDismiss()
            }
        }
    }
    
    private func formattedTime(_ sec: Int64) -> String {
        let m = sec / 60
        let s = sec % 60
        return String(format: "%02d:%02d", m, s)
    }
}
