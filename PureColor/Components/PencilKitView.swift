import SwiftUI
import PencilKit

struct PencilKitView: UIViewRepresentable {
    @Binding var canvasView: PKCanvasView
    var onDrawingBegan: (() -> Void)? = nil

    func makeUIView(context: Context) -> PKCanvasView {
        canvasView.drawingPolicy = .anyInput
        canvasView.delegate = context.coordinator
        canvasView.isOpaque = false
        canvasView.backgroundColor = .clear
        
        // Enable Zooming
        canvasView.minimumZoomScale = 1.0
        canvasView.maximumZoomScale = 5.0
        canvasView.zoomScale = 1.0
        
        return canvasView
    }

    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        uiView.delegate = context.coordinator
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, PKCanvasViewDelegate {
        var parent: PencilKitView

        init(_ parent: PencilKitView) {
            self.parent = parent
        }

        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            // Optional: Handle drawing changes
        }
        
        func canvasViewDidBeginUsingTool(_ canvasView: PKCanvasView) {
            // This is called when the user starts drawing
            parent.onDrawingBegan?()
        }
    }
}
