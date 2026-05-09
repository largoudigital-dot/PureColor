import SwiftUI

enum AgeGroup: String, CaseIterable, Identifiable, Codable {
    case toddlers = "1-3 Years"
    case kids = "4-7 Years"
    case master = "8-12 Years"
    case zen = "13+ Years"
    
    var id: String { self.rawValue }
    
    var subtitleKey: String {
        switch self {
        case .toddlers: return "Easy Play"
        case .kids: return "Creative"
        case .master: return "Artist"
        case .zen: return "Relaxation"
        }
    }
    
    var color: Color {
        switch self {
        case .toddlers: return .blue
        case .kids: return .orange
        case .master: return .purple
        case .zen: return .teal
        }
    }
    
    var icon: String {
        switch self {
        case .toddlers: return "face.smiling"
        case .kids: return "star.fill"
        case .master: return "paintpalette.fill"
        case .zen: return "leaf.fill"
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
    // --- Toddlers (1-3 Years): Basic & Big ---
    Category(name: "Big Shapes", icon: "square.on.circle.fill", color: .orange, ageGroup: .toddlers, drawings: [
        DrawingItem(imageName: "square.fill"), DrawingItem(imageName: "circle.fill"), DrawingItem(imageName: "triangle.fill"), DrawingItem(imageName: "star.fill")
    ]),
    Category(name: "My Pets", icon: "dog.fill", color: .green, ageGroup: .toddlers, drawings: [
        DrawingItem(imageName: "dog.fill"), DrawingItem(imageName: "cat.fill"), DrawingItem(imageName: "tortoise.fill"), DrawingItem(imageName: "bird.fill")
    ]),
    Category(name: "Faces & Feelings", icon: "face.smiling.fill", color: .yellow, ageGroup: .toddlers, drawings: [
        DrawingItem(imageName: "face.smiling.fill"), DrawingItem(imageName: "face.dashed.fill"), DrawingItem(imageName: "heart.fill")
    ]),
    Category(name: "Fruits", icon: "applelogo", color: .red, ageGroup: .toddlers, drawings: [
        DrawingItem(imageName: "applelogo"), DrawingItem(imageName: "leaf.fill"), DrawingItem(imageName: "sun.max.fill")
    ]),

    // --- Kids (4-7 Years): Creative & Fun ---
    Category(name: "Hero World", icon: "bolt.shield.fill", color: .blue, ageGroup: .kids, drawings: [
        DrawingItem(imageName: "bolt.shield.fill"), DrawingItem(imageName: "shield.fill"), DrawingItem(imageName: "figure.run")
    ]),
    Category(name: "Jungle", icon: "leaf.fill", color: .green, ageGroup: .kids, drawings: [
        DrawingItem(imageName: "leaf.fill"), DrawingItem(imageName: "pawprint.fill"), DrawingItem(imageName: "ant.fill")
    ]),
    Category(name: "ABC's", icon: "character.bubble.fill", color: .orange, ageGroup: .kids, drawings: [
        DrawingItem(imageName: "a.circle.fill"), DrawingItem(imageName: "b.circle.fill"), DrawingItem(imageName: "c.circle.fill")
    ]),
    Category(name: "Unicorns", icon: "sparkles", color: .pink, ageGroup: .kids, drawings: [
        DrawingItem(imageName: "sparkles"), DrawingItem(imageName: "star.fill"), DrawingItem(imageName: "heart.fill")
    ]),
    Category(name: "Vehicles", icon: "car.fill", color: .blue, ageGroup: .kids, drawings: [
        DrawingItem(imageName: "car.fill"), DrawingItem(imageName: "bus.fill"), DrawingItem(imageName: "airplane"), DrawingItem(imageName: "ferry.fill")
    ]),

    // --- Master (8-12 Years): Detailed & Advanced ---
    Category(name: "Cyber City", icon: "cpu", color: .cyan, ageGroup: .master, drawings: [
        DrawingItem(imageName: "cpu"), DrawingItem(imageName: "figure.robot"), DrawingItem(imageName: "bolt.horizontal.circle.fill")
    ]),
    Category(name: "Nature Scenery", icon: "mountain.2.fill", color: .green, ageGroup: .master, drawings: [
        DrawingItem(imageName: "mountain.2.fill"), DrawingItem(imageName: "tree.fill"), DrawingItem(imageName: "cloud.sun.fill")
    ]),
    Category(name: "Architecture", icon: "building.2.fill", color: .gray, ageGroup: .master, drawings: [
        DrawingItem(imageName: "building.2.fill"), DrawingItem(imageName: "house.fill")
    ]),

    // --- Zen (13+ Years): Relaxation & Mandalas ---
    Category(name: "Mandalas", icon: "sun.max.fill", color: .orange, ageGroup: .zen, drawings: [
        DrawingItem(imageName: "sun.max.fill"), DrawingItem(imageName: "seal.fill")
    ]),
    Category(name: "Sweet Shop", icon: "mouth.fill", color: .red, ageGroup: .zen, drawings: [
        DrawingItem(imageName: "birthday.cake.fill"), DrawingItem(imageName: "cup.and.saucer.fill")
    ]),
    Category(name: "Space", icon: "star.fill", color: .indigo, ageGroup: .zen, drawings: [
        DrawingItem(imageName: "moon.fill"), DrawingItem(imageName: "sun.max.fill"), DrawingItem(imageName: "star.fill")
    ])
]
