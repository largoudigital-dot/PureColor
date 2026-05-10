import SwiftUI
import PencilKit

enum UITheme { case playful, professional }

struct AgeGroupConfig {
    let availableColors: [Color]
    let toolCategories: [String] 
    let defaultWidth: CGFloat
    let showComplexity: Bool 
    let theme: UITheme
}

class AgeManager {
    static let shared = AgeManager()
    
    private init() {}
    
    func config(for group: AgeGroup) -> AgeGroupConfig {
        switch group {
        case .toddlers:
            return AgeGroupConfig(
                availableColors: [.red, .blue, .green, .yellow, .orange],
                toolCategories: ["Basic"],
                defaultWidth: 35.0,
                showComplexity: false,
                theme: .playful
            )
            
        case .kids:
            return AgeGroupConfig(
                availableColors: [.red, .blue, .green, .yellow, .orange, .purple, .pink, .brown, .black],
                toolCategories: ["Basic", "Sketch", "Paint"],
                defaultWidth: 15.0,
                showComplexity: true,
                theme: .playful
            )
            
        case .master: // 8-12
            return AgeGroupConfig(
                availableColors: [], 
                toolCategories: ["Basic", "Sketch", "Paint", "Ink", "Magic", "Patterns"],
                defaultWidth: 8.0,
                showComplexity: true,
                theme: .professional
            )
            
        case .zen: // 13+
            return AgeGroupConfig(
                availableColors: [],
                toolCategories: ["Basic", "Sketch", "Paint", "Ink", "Magic", "Patterns", "Shine", "Mélangeur"],
                defaultWidth: 5.0,
                showComplexity: true,
                theme: .professional
            )
        }
    }
}
