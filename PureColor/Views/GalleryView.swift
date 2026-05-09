import SwiftUI

struct GalleryView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var galleryManager = GalleryManager.shared
    
    let columns = [
        GridItem(.flexible(), spacing: 20),
        GridItem(.flexible(), spacing: 20)
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.05, green: 0.02, blue: 0.12).ignoresSafeArea()
                
                ScrollView {
                    let profileArtworks = galleryManager.savedArtworks.filter { $0.profileId == ProfileManager.shared.currentProfile.id }
                    
                    if profileArtworks.isEmpty {
                        VStack(spacing: 20) {
                            Image(systemName: "paintbrush.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.white.opacity(0.2))
                            Text(LocalizedStringKey("Your gallery is empty.\nStart coloring to see your art here!"))
                                .multilineTextAlignment(.center)
                                .foregroundColor(.white.opacity(0.5))
                        }
                        .padding(.top, 100)
                    } else {
                        LazyVGrid(columns: columns, spacing: 20) {
                            ForEach(profileArtworks) { artwork in
                                if let category = mockCategories.first(where: { $0.name == artwork.categoryName }),
                                   let drawing = category.drawings.first(where: { $0.imageName == artwork.drawingItemName }) {
                                    NavigationLink {
                                        ColoringCanvasView(category: category, drawingItem: drawing, existingArtwork: artwork)
                                    } label: {
                                        ArtworkCard(artwork: artwork)
                                    }
                                } else {
                                    ArtworkCard(artwork: artwork)
                                }
                            }
                        }
                        .padding(20)
                    }
                }
            }
            .navigationTitle(LocalizedStringKey("My Gallery"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(LocalizedStringKey("Close")) { dismiss() }
                        .foregroundColor(.white)
                }
            }
        }
    }
}

struct ArtworkCard: View {
    let artwork: SavedArtwork
    @StateObject private var galleryManager = GalleryManager.shared
    
    var body: some View {
        VStack(alignment: .leading) {
            if let uiImage = galleryManager.getImage(for: artwork) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                    .cornerRadius(15)
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 150)
                    .cornerRadius(15)
            }
            
            Text(LocalizedStringKey(artwork.categoryName))
                .font(.caption.bold())
                .foregroundColor(.white)
            Text(artwork.date, style: .date)
                .font(.system(size: 10))
                .foregroundColor(.white.opacity(0.5))
        }
        .padding(10)
        .background(RoundedRectangle(cornerRadius: 20).fill(Color.white.opacity(0.05)))
    }
}
