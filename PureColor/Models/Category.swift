import SwiftUI

enum AgeGroup: String, CaseIterable, Identifiable, Codable {
    case toddlers = "2-4 Years"
    case kids = "5-7 Years"
    case artist = "8+ Years"
    
    var id: String { self.rawValue }
    
    var color: Color {
        switch self {
        case .toddlers: return .blue
        case .kids: return .orange
        case .artist: return .purple
        }
    }
    
    var icon: String {
        switch self {
        case .toddlers: return "face.smiling"
        case .kids: return "star.fill"
        case .artist: return "paintpalette.fill"
        }
    }
}

struct DrawingItem: Identifiable, Hashable {
    let id: UUID
    let imageName: String 
    let exampleImage: String? 
    
    init(id: UUID = UUID(), imageName: String, exampleImage: String? = nil) {
        self.id = id
        self.imageName = imageName
        self.exampleImage = exampleImage
    }
}

struct Category: Identifiable, Hashable {
    let id: UUID
    let name: String
    let icon: String
    let color: Color
    let ageGroup: AgeGroup
    let drawings: [DrawingItem]
    
    init(id: UUID = UUID(), name: String, icon: String, color: Color, ageGroup: AgeGroup, drawings: [DrawingItem]) {
        self.id = id
        self.name = name
        self.icon = icon
        self.color = color
        self.ageGroup = ageGroup
        self.drawings = drawings
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Category, rhs: Category) -> Bool {
        lhs.id == rhs.id
    }
}

let mockCategories = [
    // --- Toddlers (2-4 Years) ---
    Category(name: "Big Shapes", icon: "square.on.circle.fill", color: .orange, ageGroup: .toddlers, drawings: [
        DrawingItem(imageName: "square.fill"), DrawingItem(imageName: "circle.fill"), DrawingItem(imageName: "triangle.fill"), DrawingItem(imageName: "star.fill")
    ]),
    Category(name: "Colors", icon: "paintpalette.fill", color: .pink, ageGroup: .toddlers, drawings: [
        DrawingItem(imageName: "pencil.tip"), DrawingItem(imageName: "paintbrush.fill"), DrawingItem(imageName: "drop.fill")
    ]),
    Category(name: "My Pets", icon: "dog.fill", color: .green, ageGroup: .toddlers, drawings: [
        DrawingItem(imageName: "dog.fill"), DrawingItem(imageName: "cat.fill"), DrawingItem(imageName: "tortoise.fill"), DrawingItem(imageName: "bird.fill")
    ]),
    Category(name: "Fruits", icon: "applelogo", color: .red, ageGroup: .toddlers, drawings: [
        DrawingItem(imageName: "applelogo"), DrawingItem(imageName: "leaf.fill"), DrawingItem(imageName: "sun.max.fill")
    ]),
    Category(name: "Vehicles", icon: "car.fill", color: .blue, ageGroup: .toddlers, drawings: [
        DrawingItem(imageName: "car.fill"), DrawingItem(imageName: "bus.fill"), DrawingItem(imageName: "tram.fill"), DrawingItem(imageName: "airplane"), DrawingItem(imageName: "ferry.fill")
    ]),
    Category(name: "Numbers 1-5", icon: "1.square.fill", color: .purple, ageGroup: .toddlers, drawings: [
        DrawingItem(imageName: "1.circle"), DrawingItem(imageName: "2.circle"), DrawingItem(imageName: "3.circle"), DrawingItem(imageName: "4.circle"), DrawingItem(imageName: "5.circle")
    ]),

    // --- Kids (5-7 Years) ---
    Category(name: "Jungle", icon: "leaf.fill", color: .green, ageGroup: .kids, drawings: [
        DrawingItem(imageName: "leaf.fill"), DrawingItem(imageName: "pawprint.fill"), DrawingItem(imageName: "ant.fill")
    ]),
    Category(name: "ABC's", icon: "character.bubble.fill", color: .blue, ageGroup: .kids, drawings: [
        DrawingItem(imageName: "a.circle.fill"), DrawingItem(imageName: "b.circle.fill"), DrawingItem(imageName: "c.circle.fill")
    ]),
    Category(name: "Dinosaurs", icon: "fossil.shell.fill", color: .brown, ageGroup: .kids, drawings: [
        DrawingItem(imageName: "fossil.shell.fill"), DrawingItem(imageName: "bolt.fill")
    ]),
    Category(name: "Unicorns", icon: "sparkles", color: .pink, ageGroup: .kids, drawings: [
        DrawingItem(imageName: "sparkles"), DrawingItem(imageName: "star.fill"), DrawingItem(imageName: "heart.fill")
    ]),
    Category(name: "Space", icon: "star.fill", color: .purple, ageGroup: .kids, drawings: [
        DrawingItem(imageName: "moon.fill"), DrawingItem(imageName: "sun.max.fill"), DrawingItem(imageName: "star.fill")
    ]),
    Category(name: "Ocean", icon: "water.waves", color: .blue, ageGroup: .kids, drawings: [
        DrawingItem(imageName: "fish.fill"), DrawingItem(imageName: "water.waves")
    ]),

    // --- Artist (8+ Years) ---
    Category(name: "Detailed Art", icon: "paintbrush.pointed.fill", color: .purple, ageGroup: .artist, drawings: [
        DrawingItem(imageName: "paintbrush.pointed.fill"), DrawingItem(imageName: "pencil.and.outline")
    ]),
    Category(name: "Mandalas", icon: "sun.max.fill", color: .orange, ageGroup: .artist, drawings: [
        DrawingItem(imageName: "sun.max.fill"), DrawingItem(imageName: "seal.fill")
    ]),
    Category(name: "Architecture", icon: "building.2.fill", color: .gray, ageGroup: .artist, drawings: [
        DrawingItem(imageName: "building.2.fill"), DrawingItem(imageName: "house.fill")
    ])
]
