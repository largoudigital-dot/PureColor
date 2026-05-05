import SwiftUI
import PencilKit

struct ColoringCanvasView: View {
    let category: Category
    let drawingItem: DrawingItem // Added this
    @Environment(\.dismiss) var dismiss
    
    // PencilKit State
    @State private var canvasView = PKCanvasView()
    @State private var bodyColor: Color = .white
    
    // Magic Particles
    @State private var particles: [MagicParticle] = []
    
    var body: some View {
        ZStack {
            // Sky Background
            Color(red: 0.6, green: 0.9, blue: 1.0).ignoresSafeArea()
            
            // Decorative Background
            VStack {
                HStack {
                    Image(systemName: "cloud.fill").font(.system(size: 80)).foregroundColor(.white.opacity(0.6)).offset(x: -50, y: 50)
                    Spacer()
                }
                Spacer()
            }
            
            // Magic Particles Layer
            ForEach(particles) { particle in
                SparkleView(particle: particle)
            }
            
            VStack(spacing: 0) {
                // TOP BAR: PencilKit handles tools now
                HStack {
                    Text(category.name.uppercased())
                        .font(.system(size: 24, weight: .black, design: .rounded))
                        .foregroundColor(category.color)
                        .padding(.top, 10)
                }
                
                Spacer()
                
                // CENTER: The PencilKit Canvas with Overlay Outline
                ZStack {
                    // 1. Illustrative Background Layer
                    CanvasLayer(color: bodyColor, icon: drawingItem.imageName) // Use drawingItem icon
                    
                    // 2. PencilKit Drawing Layer
                    PencilKitView(canvasView: $canvasView)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                    // 3. The Outline (Overlay)
                    Image(systemName: drawingItem.imageName) // Use drawingItem icon
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 280, height: 280)
                        .foregroundColor(.black.opacity(0.9))
                        .allowsHitTesting(false)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 30)
                        .fill(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 30)
                                .stroke(category.color, lineWidth: 15)
                        )
                )
                .padding(30)
                
                Spacer()
                
                // BOTTOM BAR: Navigation & PencilKit Controls
                HStack {
                    // Back/Cancel
                    Button { 
                        AudioManager.shared.playPop()
                        dismiss() 
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.red)
                    }
                    .handDrawn()
                    
                    Spacer()
                    
                    // Tools Cluster
                    HStack(spacing: 30) {
                        Button(action: { 
                            undo()
                            AudioManager.shared.playPop()
                        }) {
                            Image(systemName: "arrow.uturn.backward.circle.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.orange)
                        }
                        .handDrawn()
                        
                        Button(action: { 
                            clear()
                            AudioManager.shared.playPop()
                        }) {
                            Image(systemName: "trash.circle.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.gray)
                        }
                        .handDrawn()
                    }
                    
                    Spacer()
                    
                    // Done/Checkmark
                    Button {
                        saveAndExit()
                        AudioManager.shared.playSuccess()
                    } label: {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.green)
                    }
                    .handDrawn()
                }
                .padding(.horizontal, 50)
                .padding(.bottom, 30)
            }
        }
        .navigationBarBackButtonHidden(true)
    }
    
    // MARK: - PencilKit Actions
    func undo() {
        canvasView.undoManager?.undo()
    }
    
    func clear() {
        canvasView.drawing = PKDrawing()
    }
    
    @MainActor
    func saveAndExit() {
        let image = canvasView.drawing.image(from: canvasView.bounds, scale: 1.0)
        
        GalleryManager.shared.saveArtwork(
            image: image,
            category: category.name,
            profileId: ProfileManager.shared.currentProfile.id
        )
        
        ProfileManager.shared.addStar()
        dismiss()
    }
    
    func provideHapticFeedback() {
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
    }
}

// Helper Views
struct CanvasLayer: View {
    let color: Color
    let icon: String
    var body: some View {
        Image(systemName: icon)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 300, height: 300)
            .foregroundColor(color)
    }
}

struct MagicParticle: Identifiable {
    let id = UUID()
    var pos: CGPoint
    var color: Color
    var scale: CGFloat = CGFloat.random(in: 0.5...1.5)
}

struct SparkleView: View {
    let particle: MagicParticle
    @State private var opacity: Double = 1.0
    @State private var offset = CGSize.zero
    
    var body: some View {
        Image(systemName: "sparkles")
            .foregroundColor(particle.color)
            .scaleEffect(particle.scale)
            .position(particle.pos)
            .offset(offset)
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeOut(duration: 1.0)) {
                    opacity = 0
                    offset = CGSize(width: CGFloat.random(in: -50...50), height: CGFloat.random(in: -50...50))
                }
            }
    }
}

#Preview {
    ColoringCanvasView(category: mockCategories[0], drawingItem: mockCategories[0].drawings[0])
}
