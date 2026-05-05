import SwiftUI

enum AgeGroup: String, CaseIterable, Identifiable {
    case toddlers = "2-4 Years"
    case kids = "5-7 Years"
    case bigKids = "8+ Years"
    
    var id: String { self.rawValue }
    var icon: String {
        switch self {
        case .toddlers: return "face.smiling.fill"
        case .kids: return "figure.walk"
        case .bigKids: return "brain.head.profile"
        }
    }
    
    var color: Color {
        switch self {
        case .toddlers: return .orange
        case .kids: return .green
        case .bigKids: return .purple
        }
    }
}

struct Category: Identifiable, Hashable {
    let id: UUID
    let name: String
    let icon: String
    let color: Color
    let ageGroup: AgeGroup
    let type: CategoryType
    let pageCount: Int
    
    init(id: UUID = UUID(), name: String, icon: String, color: Color, ageGroup: AgeGroup, type: CategoryType, pageCount: Int) {
        self.id = id
        self.name = name
        self.icon = icon
        self.color = color
        self.ageGroup = ageGroup
        self.type = type
        self.pageCount = pageCount
    }
}

enum CategoryType: Hashable {
    case coloring
    case educational
}

let mockCategories = [
    // --- Toddlers (2-4 Years) ---
    Category(name: "Big Shapes", icon: "square.on.circle.fill", color: .orange, ageGroup: .toddlers, type: .coloring, pageCount: 20),
    Category(name: "Colors", icon: "paintpalette.fill", color: .pink, ageGroup: .toddlers, type: .educational, pageCount: 15),
    Category(name: "My Pets", icon: "dog.fill", color: .green, ageGroup: .toddlers, type: .coloring, pageCount: 12),
    Category(name: "Fruits", icon: "applelogo", color: .red, ageGroup: .toddlers, type: .educational, pageCount: 10),
    Category(name: "Vehicles", icon: "car.fill", color: .blue, ageGroup: .toddlers, type: .coloring, pageCount: 8),
    Category(name: "Numbers 1-5", icon: "1.square.fill", color: .purple, ageGroup: .toddlers, type: .educational, pageCount: 5),

    // --- Kids (5-7 Years) ---
    Category(name: "Jungle", icon: "leaf.fill", color: .green, ageGroup: .kids, type: .coloring, pageCount: 30),
    Category(name: "ABC's", icon: "character.bubble.fill", color: .blue, ageGroup: .kids, type: .educational, pageCount: 26),
    Category(name: "Dinosaurs", icon: "fossil.shell.fill", color: .brown, ageGroup: .kids, type: .coloring, pageCount: 20),
    Category(name: "Phonics", icon: "mouth.fill", color: .orange, ageGroup: .kids, type: .educational, pageCount: 15),
    Category(name: "Unicorns", icon: "sparkles", color: .pink, ageGroup: .kids, type: .coloring, pageCount: 18),
    Category(name: "Space", icon: "star.fill", color: .purple, ageGroup: .kids, type: .coloring, pageCount: 22),
    Category(name: "Ocean", icon: "water.waves", color: .blue, ageGroup: .kids, type: .coloring, pageCount: 25),
    Category(name: "Math Fun", icon: "plus.forwardslash.minus", color: .red, ageGroup: .kids, type: .educational, pageCount: 12),

    // --- Big Kids (8+ Years) ---
    Category(name: "Detailed Art", icon: "paintbrush.pointed.fill", color: .purple, ageGroup: .bigKids, type: .coloring, pageCount: 40),
    Category(name: "Learn Drawing", icon: "pencil.and.outline", color: .red, ageGroup: .bigKids, type: .educational, pageCount: 15),
    Category(name: "Mandalas", icon: "sun.max.fill", color: .orange, ageGroup: .bigKids, type: .coloring, pageCount: 20),
    Category(name: "Comics", icon: "book.closed.fill", color: .blue, ageGroup: .bigKids, type: .educational, pageCount: 12),
    Category(name: "Architecture", icon: "building.2.fill", color: .gray, ageGroup: .bigKids, type: .coloring, pageCount: 18),
    Category(name: "Fashion", icon: "tshirt.fill", color: .pink, ageGroup: .bigKids, type: .coloring, pageCount: 22)
]
