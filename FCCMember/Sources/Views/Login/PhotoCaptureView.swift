import SwiftUI
import UIKit

struct PhotoCaptureView: View {
    @Environment(\.dismiss) var dismiss
    @State private var selectedImage: UIImage?
    @State private var showCamera: Bool = true
    @State private var isUploading: Bool = false
    @State private var uploadError: String?
    
    var token: String
    var onPhotoUploaded: () -> Void
    
    var body: some View {
        ZStack {
            FCCColors.bgDark.ignoresSafeArea()
            
            VStack(spacing: 24) {
                Spacer()
                
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "person.crop.circle.badge.camera.fill")
                        .font(.system(size: 64))
                        .foregroundColor(FCCColors.gold)
                    
                    Text("Photo d'Adhérent Requise")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(FCCColors.gold)
                    
                    Text("Pour activer votre badge d'accès aux tourniquets et au club, prenez un selfie clair et de face.")
                        .font(.subheadline)
                        .foregroundColor(FCCColors.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)
                }
                
                // Photo Preview
                if let img = selectedImage {
                    Image(uiImage: img)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 200, height: 200)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(FCCColors.gold, lineWidth: 3))
                        .shadow(color: FCCColors.gold.opacity(0.4), radius: 10)
                } else {
                    Circle()
                        .fill(FCCColors.cardBg)
                        .frame(width: 200, height: 200)
                        .overlay(
                            Image(systemName: "camera.fill")
                                .font(.system(size: 50))
                                .foregroundColor(FCCColors.gold.opacity(0.6))
                        )
                }
                
                if let err = uploadError {
                    Text(err)
                        .font(.caption)
                        .foregroundColor(FCCColors.errorRed)
                }
                
                Spacer()
                
                // Actions
                VStack(spacing: 12) {
                    if selectedImage == nil {
                        Button(action: { showCamera = true }) {
                            HStack {
                                Image(systemName: "camera.fill")
                                Text("Ouvrir la Caméra")
                                    .fontWeight(.bold)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(FCCColors.gold)
                            .foregroundColor(.black)
                            .cornerRadius(14)
                        }
                    } else {
                        Button(action: uploadImage) {
                            HStack {
                                if isUploading {
                                    ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .black))
                                } else {
                                    Text("Confirmer et Continuer")
                                        .fontWeight(.bold)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(FCCColors.gold)
                            .foregroundColor(.black)
                            .cornerRadius(14)
                        }
                        .disabled(isUploading)
                        
                        Button("Reprendre la photo") {
                            selectedImage = nil
                            showCamera = true
                        }
                        .foregroundColor(FCCColors.textSecondary)
                        .font(.subheadline)
                    }
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 20)
            }
        }
        .fullScreenCover(isPresented: $showCamera) {
            ImagePicker(selectedImage: $selectedImage)
        }
    }
    
    private func uploadImage() {
        guard let img = selectedImage else { return }
        isUploading = true
        uploadError = nil
        
        // Convert to optimized JPEG
        guard let jpegData = img.jpegData(compressionQuality: 0.8) else {
            isUploading = false
            uploadError = "Format d'image non valide."
            return
        }
        
        let base64 = "data:image/jpeg;base64," + jpegData.base64EncodedString()
        
        Task {
            do {
                try await MemberAPIService.shared.uploadPhoto(token: token, base64Photo: base64)
                await MainActor.run {
                    isUploading = false
                    onPhotoUploaded()
                }
            } catch {
                await MainActor.run {
                    isUploading = false
                    uploadError = error.localizedDescription
                }
            }
        }
    }
}

// Simple UIImagePickerController wrapper for native iOS camera
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.dismiss) var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            picker.sourceType = .camera
            picker.cameraDevice = .front
        } else {
            picker.sourceType = .photoLibrary
        }
        picker.allowsEditing = true
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        init(_ parent: ImagePicker) { self.parent = parent }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let edited = info[.editedImage] as? UIImage {
                parent.selectedImage = edited
            } else if let orig = info[.originalImage] as? UIImage {
                parent.selectedImage = orig
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}
