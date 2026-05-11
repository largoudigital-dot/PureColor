import SwiftUI

enum GalleryTab: String, CaseIterable {
    case all = "All"
    case finished = "Finished"
    case drafts = "Drafts"
}

struct GalleryView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var galleryManager = GalleryManager.shared
    @State private var selectedTab: GalleryTab = .all
    
    private var columns: [GridItem] {
        let count = UIDevice.current.userInterfaceIdiom == .pad ? 3 : 2
        return Array(repeating: GridItem(.flexible(), spacing: 20), count: count)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.05, green: 0.02, blue: 0.12).ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Modern Header with Profile
                    HStack(spacing: 15) {
                        Image(systemName: ProfileManager.shared.currentProfile.avatar)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 45, height: 45)
                            .padding(8)
                            .background(Circle().fill(Color.white.opacity(0.1)))
                            .foregroundColor(.white)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(ProfileManager.shared.currentProfile.name.isEmpty ? LocalizedStringKey("Guest Artist") : LocalizedStringKey(ProfileManager.shared.currentProfile.name))
                                .font(.headline.bold())
                                .foregroundColor(.white)
                            Text(LocalizedStringKey("Creative Studio"))
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.5))
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal, 25)
                    .padding(.top, 10)
                    
                    // Modern Tab Switcher
                    HStack(spacing: 0) {
                        ForEach(GalleryTab.allCases, id: \.self) { tab in
                            Button {
                                withAnimation(.spring()) { selectedTab = tab }
                                AudioManager.shared.playPop()
                            } label: {
                                Text(LocalizedStringKey(tab.rawValue))
                                    .font(.headline.bold())
                                    .padding(.vertical, 10)
                                    .frame(maxWidth: .infinity)
                                    .background(selectedTab == tab ? Color.blue : Color.clear)
                                    .foregroundColor(selectedTab == tab ? .white : .white.opacity(0.4))
                                    .cornerRadius(12)
                            }
                            .padding(4)
                        }
                    }
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(15)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 15)
                    
                    ScrollView {
                        let profileArtworks = galleryManager.savedArtworks.filter { artwork in
                            let matchesProfile = artwork.profileId == ProfileManager.shared.currentProfile.id
                            switch selectedTab {
                            case .all: return matchesProfile
                            case .finished: return matchesProfile && artwork.isFinished
                            case .drafts: return matchesProfile && !artwork.isFinished
                            }
                        }
                        
                        if profileArtworks.isEmpty {
                            VStack(spacing: 20) {
                                Image(systemName: "paintbrush.fill")
                                    .font(.system(size: 60))
                                    .foregroundColor(.white.opacity(0.2))
                                Text(LocalizedStringKey("No artwork found here!"))
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(.white.opacity(0.5))
                            }
                            .padding(.top, 100)
                        } else {
                            LazyVGrid(columns: columns, spacing: 25) {
                                ForEach(profileArtworks) { artwork in
                                    // Resume drawing logic
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
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Text(LocalizedStringKey("My Gallery"))
                        .font(.title3.bold())
                        .foregroundColor(.white)
                }
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
    @State private var showDeleteConfirmation = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack(alignment: .topTrailing) {
                if let uiImage = galleryManager.getImage(for: artwork) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                        .background(Color.white)
                        .cornerRadius(18)
                        .shadow(color: .black.opacity(0.3), radius: 10, y: 5)
                } else {
                    RoundedRectangle(cornerRadius: 18)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 180)
                }
                
                // Delete Button (Top Left)
                HStack {
                    Button {
                        AudioManager.shared.playPop()
                        showDeleteConfirmation = true
                    } label: {
                        Image(systemName: "trash.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.red.opacity(0.8))
                            .background(Circle().fill(Color.white))
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(8)
                    
                    Spacer()
                    
                    // Status Badges (Top Right)
                    VStack(alignment: .trailing, spacing: 6) {
                        Text(LocalizedStringKey(artwork.isFinished ? "Finished" : "Draft"))
                            .font(.system(size: 9, weight: .black))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(artwork.isFinished ? Color.green : Color.orange)
                            .foregroundColor(.white)
                            .cornerRadius(6)
                        
                        Text(ageRangeText(for: artwork.ageGroup))
                            .font(.system(size: 9, weight: .black))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.purple)
                            .foregroundColor(.white)
                            .cornerRadius(6)
                    }
                    .padding(10)
                }
                .shadow(radius: 3)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(LocalizedStringKey(artwork.categoryName))
                    .font(.headline.bold())
                    .foregroundColor(.white)
                
                HStack {
                    Image(systemName: "calendar")
                    Text(artwork.date, style: .date)
                }
                .font(.caption)
                .foregroundColor(.white.opacity(0.6))
            }
            .padding(.horizontal, 5)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(LinearGradient(colors: [Color.white.opacity(0.1), Color.white.opacity(0.02)], startPoint: .topLeading, endPoint: .bottomTrailing))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 25)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
        .alert(isPresented: $showDeleteConfirmation) {
            Alert(
                title: Text(LocalizedStringKey("Delete Artwork?")),
                message: Text(LocalizedStringKey("This cannot be undone.")),
                primaryButton: .destructive(Text(LocalizedStringKey("Delete"))) {
                    galleryManager.deleteArtwork(artwork)
                },
                secondaryButton: .cancel()
            )
        }
    }
    
    private func ageRangeText(for group: AgeGroup) -> String {
        switch group {
        case .toddlers: return "1-3"
        case .kids: return "4-7"
        case .master: return "8-12"
        case .zen: return "13+"
        }
    }
}
