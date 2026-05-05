import SwiftUI
import Combine

class WorldManager: ObservableObject {
    static let shared = WorldManager()
    
    @Published var currentAgeGroup: AgeGroup = .toddlers
    @Published var unlockedCategories: Set<UUID> = []
    @Published var selectedCategory: Category? = nil
    
    // Logic for loading different worlds/themes
    func categories(for age: AgeGroup) -> [Category] {
        return mockCategories.filter { $0.ageGroup == age }
    }
    
    func unlockAll() {
        // Logic for One-Time Purchase
    }
    
    // Sound & Haptic central control
    func playSound(named name: String) {
        // Placeholder for audio engine
    }
}
