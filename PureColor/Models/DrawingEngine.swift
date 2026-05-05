import SwiftUI
import Combine

struct DrawingStroke: Identifiable {
    let id = UUID()
    var points: [CGPoint]
    var color: Color
    var lineWidth: CGFloat
}

class DrawingEngine: ObservableObject {
    @Published var strokes: [DrawingStroke] = []
    @Published var currentStroke: DrawingStroke?
    
    func addPoint(_ point: CGPoint, color: Color, lineWidth: CGFloat) {
        if currentStroke == nil {
            currentStroke = DrawingStroke(points: [point], color: color, lineWidth: lineWidth)
        } else {
            currentStroke?.points.append(point)
        }
    }
    
    func endStroke() {
        if let stroke = currentStroke {
            strokes.append(stroke)
        }
        currentStroke = nil
    }
    
    func clear() {
        strokes = []
    }
    
    func undo() {
        if !strokes.isEmpty {
            strokes.removeLast()
        }
    }
}
