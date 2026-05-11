import SwiftUI
import AVFoundation
import Photos
import Combine

class TimeLapseRecorder: ObservableObject {
    static let shared = TimeLapseRecorder()
    
    @Published var isRecording = false
    private var images: [UIImage] = []
    private var timer: Timer?
    
    private var backgroundColors: [UIColor] = [.white]
    private var backgroundImage: UIImage?
    private var backgroundOpacity: CGFloat = 0.5

    func startRecording(canvas: UIView, background: UIImage?, bgColors: [Color], opacity: CGFloat = 0.5) {
        images.removeAll()
        self.backgroundImage = background
        self.backgroundColors = bgColors.map { UIColor($0) }
        self.backgroundOpacity = opacity
        isRecording = true
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            let renderer = UIGraphicsImageRenderer(bounds: canvas.bounds)
            let image = renderer.image { ctx in
                // 1. Draw Background
                if self.backgroundColors.count > 1 {
                    // Draw Gradient
                    let colors = self.backgroundColors.map { $0.cgColor } as CFArray
                    let colorSpace = CGColorSpaceCreateDeviceRGB()
                    let gradient = CGGradient(colorsSpace: colorSpace, colors: colors, locations: nil)!
                    
                    ctx.cgContext.drawLinearGradient(
                        gradient,
                        start: CGPoint(x: 0, y: 0),
                        end: CGPoint(x: canvas.bounds.width, y: canvas.bounds.height),
                        options: []
                    )
                } else {
                    // Draw Solid
                    (self.backgroundColors.first ?? .white).set()
                    ctx.fill(canvas.bounds)
                }
                
                // 2. Draw the reference drawing if exists
                if let bg = self.backgroundImage {
                    let aspectRect = self.getAspectFitRect(for: bg, in: canvas.bounds)
                    bg.draw(in: aspectRect, blendMode: .normal, alpha: self.backgroundOpacity)
                }
                
                // 3. Draw the user's drawing
                canvas.drawHierarchy(in: canvas.bounds, afterScreenUpdates: false)
            }
            self.images.append(image)
        }
    }
    
    private func getAspectFitRect(for image: UIImage, in rect: CGRect) -> CGRect {
        let imageRatio = image.size.width / image.size.height
        let viewRatio = rect.width / rect.height
        
        var resultRect = rect.insetBy(dx: 40, dy: 40) // Match the padding in SwiftUI
        
        if imageRatio > viewRatio {
            let height = resultRect.width / imageRatio
            resultRect.origin.y += (resultRect.height - height) / 2
            resultRect.size.height = height
        } else {
            let width = resultRect.height * imageRatio
            resultRect.origin.x += (resultRect.width - width) / 2
            resultRect.size.width = width
        }
        return resultRect
    }
    
    func stopAndExport(completion: @escaping (URL?) -> Void) {
        timer?.invalidate()
        timer = nil
        isRecording = false
        
        guard !images.isEmpty else {
            completion(nil)
            return
        }
        
        exportVideo(from: images, completion: completion)
    }
    
    private func exportVideo(from images: [UIImage], completion: @escaping (URL?) -> Void) {
        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent("timelapse_\(UUID().uuidString).mp4")
        
        guard let firstImage = images.first else {
            completion(nil)
            return
        }
        
        let scale = firstImage.scale
        let width = Int(firstImage.size.width * scale) / 2 * 2
        let height = Int(firstImage.size.height * scale) / 2 * 2
        let pixelSize = CGSize(width: width, height: height)
        
        try? FileManager.default.removeItem(at: outputURL)
        
        guard let videoWriter = try? AVAssetWriter(outputURL: outputURL, fileType: .mp4) else {
            completion(nil)
            return
        }
        
        let videoSettings: [String: Any] = [
            AVVideoCodecKey: AVVideoCodecType.h264,
            AVVideoWidthKey: width,
            AVVideoHeightKey: height
        ]
        
        let writerInput = AVAssetWriterInput(mediaType: .video, outputSettings: videoSettings)
        writerInput.expectsMediaDataInRealTime = false
        
        let sourcePixelBufferAttributes: [String: Any] = [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA,
            kCVPixelBufferWidthKey as String: width,
            kCVPixelBufferHeightKey as String: height
        ]
        
        let adapter = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: writerInput, sourcePixelBufferAttributes: sourcePixelBufferAttributes)
        
        videoWriter.add(writerInput)
        videoWriter.startWriting()
        videoWriter.startSession(atSourceTime: .zero)
        
        let frameDuration = CMTime(value: 1, timescale: 10)
        var currentFrameTime = CMTime.zero
        
        DispatchQueue.global(qos: .userInitiated).async {
            for image in images {
                autoreleasepool {
                    while !writerInput.isReadyForMoreMediaData {
                        Thread.sleep(forTimeInterval: 0.01)
                    }
                    
                    if videoWriter.status == .writing {
                        if let pixelBuffer = self.pixelBuffer(from: image, size: pixelSize) {
                            adapter.append(pixelBuffer, withPresentationTime: currentFrameTime)
                            currentFrameTime = CMTimeAdd(currentFrameTime, frameDuration)
                        }
                    }
                }
                
                if videoWriter.status == .failed { break }
            }
            
            writerInput.markAsFinished()
            videoWriter.finishWriting {
                DispatchQueue.main.async {
                    if videoWriter.status == .completed {
                        completion(outputURL)
                    } else {
                        print("Video Writer Error: \(videoWriter.error?.localizedDescription ?? "unknown")")
                        completion(nil)
                    }
                }
            }
        }
    }
    
    private func pixelBuffer(from image: UIImage, size: CGSize) -> CVPixelBuffer? {
        let width = Int(size.width)
        let height = Int(size.height)
        
        let options: [String: Any] = [
            kCVPixelBufferCGImageCompatibilityKey as String: true,
            kCVPixelBufferCGBitmapContextCompatibilityKey as String: true
        ]
        
        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault, width, height, kCVPixelFormatType_32BGRA, options as CFDictionary, &pixelBuffer)
        
        guard status == kCVReturnSuccess, let buffer = pixelBuffer, let cgImage = image.cgImage else { return nil }
        
        CVPixelBufferLockBaseAddress(buffer, [])
        let data = CVPixelBufferGetBaseAddress(buffer)
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: data, width: width, height: height, bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(buffer), space: colorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue)
        
        context?.draw(cgImage, in: CGRect(origin: .zero, size: size))
        
        CVPixelBufferUnlockBaseAddress(buffer, [])
        return buffer
    }
}
