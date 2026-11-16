import SwiftUI

@main
struct FCCMemberApp: App {
    @StateObject private var sessionManager = SessionManager.shared
    @State private var requiresPhoto: Bool = false
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                FCCColors.bgDark.ignoresSafeArea()
                
                if sessionManager.isLoggedIn {
                    if requiresPhoto, let token = sessionManager.token {
                        PhotoCaptureView(token: token) {
                            self.requiresPhoto = false
                        }
                    } else {
                        DashboardView(
                            onRequirePhoto: {
                                self.requiresPhoto = true
                            },
                            onLogout: {
                                self.requiresPhoto = false
                            }
                        )
                    }
                } else {
                    LoginView { response in
                        if response.data.photo == nil || response.data.photo?.isEmpty == true {
                            self.requiresPhoto = true
                        }
                    }
                }
            }
            .preferredColorScheme(.dark)
        }
    }
}
