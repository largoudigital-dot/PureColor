import SwiftUI
import Combine

struct SavedArtwork: Identifiable, Codable {
    let id: UUID
    let categoryName: String
    let date: Date
    let fileName: String
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
    
    func saveArtwork(image: UIImage, category: String) {
        let id = UUID()
        let fileName = "\(id.uuidString).png"
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        
        if let data = image.pngData() {
            try? data.write(to: fileURL)
            
            let artwork = SavedArtwork(id: id, categoryName: category, date: Date(), fileName: fileName)
            savedArtworks.insert(artwork, at: 0)
            saveArtworksMetadata()
        }
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
}
