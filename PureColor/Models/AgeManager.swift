import SwiftUI
import PencilKit

struct AgeGroupConfig {
    let availableColors: [Color]
    let toolCategories: [String] // e.g. ["Basic"] for toddlers, all for artist
    let defaultWidth: CGFloat
    let showComplexity: Bool // If true, show detailed settings
}

class AgeManager {
    static let shared = AgeManager()
    
    private init() {}
    
    func config(for group: AgeGroup) -> AgeGroupConfig {
        switch group {
        case .toddlers:
            return AgeGroupConfig(
                availableColors: [.red, .blue, .green, .yellow, .orange], // Only 5 basic colors
                toolCategories: ["Basic"], // Only basic pens
                defaultWidth: 35.0,
                showComplexity: false
            )
            
        case .kids:
            return AgeGroupConfig(
                availableColors: [.red, .blue, .green, .yellow, .orange, .purple, .pink, .brown, .black],
                toolCategories: ["Basic", "Sketch"],
                defaultWidth: 15.0,
                showComplexity: true
            )
            
        case .master:
            return AgeGroupConfig(
                availableColors: [], // Empty means show full color picker/all colors
                toolCategories: ["Basic", "Sketch", "Paint", "Ink"],
                defaultWidth: 5.0,
                showComplexity: true
            )
            
        case .zen:
            return AgeGroupConfig(
                availableColors: [],
                toolCategories: ["Basic", "Sketch", "Paint", "Ink", "Magic", "Patterns"],
                defaultWidth: 2.0,
                showComplexity: true
            )
        }
    }
}
