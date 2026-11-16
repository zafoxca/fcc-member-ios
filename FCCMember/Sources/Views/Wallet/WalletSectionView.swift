import SwiftUI

struct WalletSectionView: View {
    let wallet: WalletData?
    let isFamily: Bool
    var onGenerateKioskCode: () -> Void
    
    @State private var showHistorySheet: Bool = false
    
    var body: some View {
        VStack(spacing: 14) {
            // Header
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "creditcard.fill")
                        .foregroundColor(FCCColors.gold)
                    Text("MON WALLET RTCF")
                        .font(.system(size: 13, weight: .heavy))
                        .foregroundColor(FCCColors.gold)
                        .tracking(1)
                }
                Spacer()
                if let txs = wallet?.transactions, !txs.isEmpty {
                    Button(action: { showHistorySheet = true }) {
                        HStack(spacing: 4) {
                            Text("Historique")
                                .font(.caption)
                                .fontWeight(.bold)
                            Image(systemName: "chevron.right")
                                .font(.caption2)
                        }
                        .foregroundColor(FCCColors.gold)
                    }
                }
            }
            .padding(.horizontal, 20)
            
            if let w = wallet {
                // Card View
                ZStack {
                    LinearGradient(
                        colors: [Color(hex: "1E4633"), Color(hex: "0F2B1D"), Color(hex: "081C15")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    
                    VStack(alignment: .leading, spacing: 18) {
                        // Card Top Row
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(isFamily ? "PORTEFEUILLE FAMILIAL" : "PORTEFEUILLE ADHÉRENT")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(FCCColors.gold.opacity(0.85))
                                    .tracking(1)
                                
                                Text(String(format: "%.2f DH", w.safeTotalBalance))
                                    .font(.system(size: 30, weight: .heavy))
                                    .foregroundColor(.white)
                            }
                            Spacer()
                            Image(systemName: "wave.3.right.circle.fill")
                                .font(.system(size: 28))
                                .foregroundColor(FCCColors.gold)
                        }
                        
                        // Cashback / Details Row
                        HStack {
                            if w.safeCashback > 0 {
                                HStack(spacing: 4) {
                                    Image(systemName: "gift.fill")
                                        .font(.caption2)
                                    Text(String(format: "Dont Cashback: +%.2f DH", w.safeCashback))
                                        .font(.caption2)
                                        .fontWeight(.semibold)
                                }
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.black.opacity(0.3))
                                .foregroundColor(FCCColors.gold)
                                .cornerRadius(8)
                            }
                            
                            Spacer()
                            
                            if let cardNo = w.rfid_card_number, !cardNo.isEmpty {
                                HStack(spacing: 4) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.caption2)
                                    Text("Carte RFID Liée")
                                        .font(.caption2)
                                        .fontWeight(.semibold)
                                }
                                .foregroundColor(FCCColors.successGreen)
                            }
                        }
                        
                        Divider().background(Color.white.opacity(0.15))
                        
                        // Bottom Actions: Kiosk Code button
                        Button(action: onGenerateKioskCode) {
                            HStack {
                                Image(systemName: "qrcode.viewfinder")
                                    .font(.headline)
                                Text("Paiement Kiosque (Code Borne 15 min)")
                                    .font(.system(size: 13, weight: .bold))
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 42)
                            .background(FCCColors.gold)
                            .foregroundColor(.black)
                            .cornerRadius(12)
                        }
                    }
                    .padding(20)
                }
                .cornerRadius(22)
                .overlay(
                    RoundedRectangle(cornerRadius: 22)
                        .stroke(FCCColors.gold.opacity(0.3), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.4), radius: 10, x: 0, y: 6)
                .padding(.horizontal, 20)
                
            } else {
                Text("Aucun portefeuille numérique actif associé à ce compte.")
                    .font(.caption)
                    .foregroundColor(FCCColors.textSecondary)
                    .padding(20)
                    .frame(maxWidth: .infinity)
                    .background(FCCColors.cardBg)
                    .cornerRadius(16)
                    .padding(.horizontal, 20)
            }
        }
        .sheet(isPresented: $showHistorySheet) {
            WalletHistorySheet(transactions: wallet?.transactions ?? [])
        }
    }
}

struct WalletHistorySheet: View {
    let transactions: [WalletTransactionData]
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            List(transactions) { tx in
                HStack(spacing: 12) {
                    Image(systemName: tx.type == "credit" ? "arrow.down.left.circle.fill" : "arrow.up.right.circle.fill")
                        .font(.title2)
                        .foregroundColor(tx.type == "credit" ? FCCColors.successGreen : FCCColors.errorRed)
                    
                    VStack(alignment: .leading, spacing: 3) {
                        Text(tx.description ?? (tx.type == "credit" ? "Recharge Portefeuille" : "Paiement"))
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(FCCColors.textPrimary)
                        Text(tx.date)
                            .font(.caption2)
                            .foregroundColor(FCCColors.textSecondary)
                    }
                    
                    Spacer()
                    
                    Text(String(format: "%@%.2f DH", tx.type == "credit" ? "+" : "-", tx.amount))
                        .font(.subheadline)
                        .fontWeight(.heavy)
                        .foregroundColor(tx.type == "credit" ? FCCColors.successGreen : FCCColors.textPrimary)
                }
                .listRowBackground(FCCColors.cardBg)
            }
            .background(FCCColors.bgDark.ignoresSafeArea())
            .scrollContentBackground(.hidden)
            .navigationTitle("Historique Wallet")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Fermer") { dismiss() }
                        .foregroundColor(FCCColors.gold)
                }
            }
        }
    }
}
