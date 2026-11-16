import SwiftUI
import CoreImage.CIFilterBuiltins

struct QRCodeHelper {
    static let context = CIContext()
    static let filter = CIFilter.qrCodeGenerator()
    
    static func generateQRCode(from string: String, size: CGFloat = 260) -> UIImage? {
        filter.message = Data(string.utf8)
        filter.correctionLevel = "M"
        
        guard let outputImage = filter.outputImage else { return nil }
        
        let scaleX = size / outputImage.extent.size.width
        let scaleY = size / outputImage.extent.size.height
        let transformedImage = outputImage.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))
        
        if let cgImage = context.createCGImage(transformedImage, from: transformedImage.extent) {
            return UIImage(cgImage: cgImage)
        }
        return nil
    }
}
