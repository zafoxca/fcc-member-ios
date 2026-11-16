import SwiftUI

struct NotificationsSheetView: View {
    @Binding var notifications: [NotificationData]
    var token: String
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            Group {
                if notifications.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "bell.slash.fill")
                            .font(.system(size: 48))
                            .foregroundColor(FCCColors.gold.opacity(0.5))
                        Text("Aucune notification")
                            .font(.headline)
                            .foregroundColor(FCCColors.textPrimary)
                        Text("Vous êtes à jour avec toutes les actualités du club.")
                            .font(.caption)
                            .foregroundColor(FCCColors.textSecondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(notifications) { notif in
                            VStack(alignment: .leading, spacing: 6) {
                                HStack {
                                    if !notif.read {
                                        Circle()
                                            .fill(FCCColors.gold)
                                            .frame(width: 8, height: 8)
                                    }
                                    Text(notif.title)
                                        .font(.subheadline)
                                        .fontWeight(notif.read ? .semibold : .bold)
                                        .foregroundColor(FCCColors.textPrimary)
                                    Spacer()
                                    Text(notif.created_at)
                                        .font(.caption2)
                                        .foregroundColor(FCCColors.textSecondary)
                                }
                                Text(notif.body)
                                    .font(.caption)
                                    .foregroundColor(FCCColors.textSecondary)
                            }
                            .padding(.vertical, 4)
                            .listRowBackground(notif.read ? FCCColors.cardBg : FCCColors.cardLight)
                            .onTapGesture {
                                markAsRead(notif.id)
                            }
                        }
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .background(FCCColors.bgDark.ignoresSafeArea())
            .navigationTitle("Notifications")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    if notifications.contains(where: { !$0.read }) {
                        Button("Tout lire") {
                            markAllAsRead()
                        }
                        .foregroundColor(FCCColors.gold)
                        .font(.caption)
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Fermer") { dismiss() }
                        .foregroundColor(FCCColors.gold)
                        .fontWeight(.bold)
                }
            }
        }
    }
    
    private func markAsRead(_ id: Int64) {
        if let idx = notifications.firstIndex(where: { $0.id == id }) {
            notifications[idx] = NotificationData(
                id: notifications[idx].id,
                title: notifications[idx].title,
                body: notifications[idx].body,
                type: notifications[idx].type,
                read: true,
                created_at: notifications[idx].created_at
            )
        }
        Task {
            try? await MemberAPIService.shared.markNotificationRead(token: token, id: id)
        }
    }
    
    private func markAllAsRead() {
        notifications = notifications.map {
            NotificationData(id: $0.id, title: $0.title, body: $0.body, type: $0.type, read: true, created_at: $0.created_at)
        }
        Task {
            try? await MemberAPIService.shared.markAllNotificationsRead(token: token)
        }
    }
}
