import SwiftUI

struct LegalComplianceView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Group {
                        Text("Conditions Générales d'Utilisation (CGU)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(FCCColors.gold)
                        
                        Text("Bienvenue sur l'application officielle du Fès Country Club (Royal Tennis Club de Fès). L'accès et l'utilisation de cette application sont réservés exclusivement aux adhérents en règle et membres de leurs familles.")
                            .font(.body)
                            .foregroundColor(FCCColors.textPrimary)
                    }
                    
                    Divider().background(FCCColors.gold.opacity(0.3))
                    
                    Group {
                        Text("Protection des Données Personnelles (Loi 09-08 / CNDP)")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(FCCColors.gold)
                        
                        Text("Conformément à la loi n° 09-08 relative à la protection des personnes physiques à l'égard du traitement des données à caractère personnel, vos informations (identité, coordonnées, historique d'accès biométrique et portefeuille RTCF) sont collectées exclusivement pour la gestion des accès, de la sécurité et des services du club.")
                            .font(.body)
                            .foregroundColor(FCCColors.textSecondary)
                        
                        Text("Les données ne sont en aucun cas commercialisées ou partagées avec des tiers extérieurs.")
                            .font(.body)
                            .foregroundColor(FCCColors.textSecondary)
                    }
                    
                    Divider().background(FCCColors.gold.opacity(0.3))
                    
                    Group {
                        Text("Portefeuille & Paiement Kiosque (Wallet RTCF)")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(FCCColors.gold)
                        
                        Text("Le code temporaire à 6 chiffres généré pour le paiement borne kiosque a une validité stricte de 15 minutes à usage unique. Il est personnel et ne doit pas être divulgué.")
                            .font(.body)
                            .foregroundColor(FCCColors.textSecondary)
                    }
                    
                    Spacer(minLength: 30)
                }
                .padding(24)
            }
            .background(FCCColors.bgDark.ignoresSafeArea())
            .navigationTitle("Mentions Légales")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Fermer") { dismiss() }
                        .foregroundColor(FCCColors.gold)
                        .fontWeight(.bold)
                }
            }
        }
    }
}
