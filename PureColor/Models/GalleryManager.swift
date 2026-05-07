import SwiftUI
import Combine
import PencilKit

struct SavedArtwork: Identifiable, Codable {
    let id: UUID
    let profileId: UUID
    let categoryName: String
    let drawingItemName: String // Added: to know which template was used
    let date: Date
    let fileName: String
    let drawingFileName: String // Added: to store PKDrawing data
}

class GalleryManager: ObservableObject {
    static let shared = GalleryManager()
    
    @Published var savedArtworks: [SavedArtwork] = []
    
    private init() {
        loadArtworks()
    }
    
    private var documentsDirectory: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    func saveArtwork(image: UIImage, drawing: PKDrawing, category: String, drawingItemName: String, profileId: UUID, existingId: UUID? = nil) {
        let id = existingId ?? UUID()
        let fileName = "\(id.uuidString).png"
        let drawingFileName = "\(id.uuidString).pkdrawing"
        
        let imageURL = documentsDirectory.appendingPathComponent(fileName)
        let drawingURL = documentsDirectory.appendingPathComponent(drawingFileName)
        
        // Save Image
        if let data = image.pngData() {
            try? data.write(to: imageURL)
        }
        
        // Save Drawing Data
        let drawingData = drawing.dataRepresentation()
        try? drawingData.write(to: drawingURL)
        
        let artwork = SavedArtwork(
            id: id,
            profileId: profileId,
            categoryName: category,
            drawingItemName: drawingItemName,
            date: Date(),
            fileName: fileName,
            drawingFileName: drawingFileName
        )
        
        if let index = savedArtworks.firstIndex(where: { $0.id == id }) {
            savedArtworks[index] = artwork
        } else {
            savedArtworks.insert(artwork, at: 0)
        }
        
        saveArtworksMetadata()
    }
    
    func loadArtworks() {
        if let data = UserDefaults.standard.data(forKey: "saved_artworks_metadata"),
           let decoded = try? JSONDecoder().decode([SavedArtwork].self, from: data) {
            savedArtworks = decoded
        }
    }
    
    private func saveArtworksMetadata() {
        if let encoded = try? JSONEncoder().encode(savedArtworks) {
            UserDefaults.standard.set(encoded, forKey: "saved_artworks_metadata")
        }
    }
    
    func getImage(for artwork: SavedArtwork) -> UIImage? {
        let fileURL = documentsDirectory.appendingPathComponent(artwork.fileName)
        if let data = try? Data(contentsOf: fileURL) {
            return UIImage(data: data)
        }
        return nil
    }
    
    func getDrawing(for artwork: SavedArtwork) -> PKDrawing? {
        let fileURL = documentsDirectory.appendingPathComponent(artwork.drawingFileName)
        if let data = try? Data(contentsOf: fileURL) {
            return try? PKDrawing(data: data)
        }
        return nil
    }
}
