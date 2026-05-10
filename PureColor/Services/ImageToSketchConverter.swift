import UIKit
import CoreImage
import CoreImage.CIFilterBuiltins

class ImageToSketchConverter {
    static let shared = ImageToSketchConverter()
    let context = CIContext()

    func convertToLineArt(image: UIImage, completion: @escaping (UIImage?) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            guard let ciImage = CIImage(image: image) else {
                DispatchQueue.main.async { completion(nil) }
                return
            }
            
            // 1. Convert to grayscale
            let monoFilter = CIFilter.colorControls()
            monoFilter.inputImage = ciImage
            monoFilter.saturation = 0.0
            monoFilter.contrast = 1.1
            guard let monoImage = monoFilter.outputImage else {
                DispatchQueue.main.async { completion(nil) }
                return
            }
            
            // 2. Invert the grayscale image
            let invertFilter = CIFilter.colorInvert()
            invertFilter.inputImage = monoImage
            guard let invertedImage = invertFilter.outputImage else {
                DispatchQueue.main.async { completion(nil) }
                return
            }
            
            // 3. Blur the inverted image
            let blurFilter = CIFilter.gaussianBlur()
            blurFilter.inputImage = invertedImage
            blurFilter.radius = 3.0 // Lower radius for sharper lines
            guard let blurredImage = blurFilter.outputImage else {
                DispatchQueue.main.async { completion(nil) }
                return
            }
            
            // 4. Blend using Color Dodge to get sketch effect
            let blendFilter = CIFilter.colorDodgeBlendMode()
            blendFilter.inputImage = blurredImage
            blendFilter.backgroundImage = monoImage
            
            guard let outputImage = blendFilter.outputImage,
                  let cgImage = self.context.createCGImage(outputImage, from: outputImage.extent) else {
                DispatchQueue.main.async { completion(nil) }
                return
            }
            
            let sketchImage = UIImage(cgImage: cgImage)
            
            DispatchQueue.main.async {
                completion(sketchImage)
            }
        }
    }
}
