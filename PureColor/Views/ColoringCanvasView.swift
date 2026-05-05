import SwiftUI
import Combine

struct ColoringCanvasView: View {
    let category: Category
    @Environment(\.dismiss) var dismiss
    
    @StateObject private var engine = DrawingEngine()
    @State private var selectedColor: Color = .red
    @State private var bodyColor: Color = .white
    @State private var brushSize: CGFloat = 12
    
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
                // TOP BAR: Crayons & Markers (Match Screenshot 3)
                HStack(spacing: 15) {
                    ForEach([Color.red, .orange, .yellow, .green, .blue, .purple, .pink, .brown, .black], id: \.self) { color in
                        CrayonButton(color: color, isSelected: selectedColor == color) {
                            selectedColor = color
                            provideHapticFeedback()
                        }
                    }
                }
                .padding(.top, 20)
                .padding(.bottom, 10)
                .background(
                    Rectangle()
                        .fill(Color.white.opacity(0.8))
                        .shadow(radius: 5)
                )
                
                Spacer()
                
                // CENTER: The Canvas with Thick Border (Match Screenshot 2/3)
                ZStack {
                    // 1. Illustrative Layers
                    CanvasLayer(color: bodyColor, icon: category.icon)
                        .onTapGesture {
                            withAnimation(.spring()) { bodyColor = selectedColor }
                            createExplosion(at: CGPoint(x: 200, y: 200))
                            provideHapticFeedback()
                        }
                    
                    // 2. Free Drawing Layer
                    Canvas { context, size in
                        for stroke in engine.strokes {
                            var path = Path()
                            path.addLines(stroke.points)
                            context.stroke(path, with: .color(stroke.color), style: StrokeStyle(lineWidth: stroke.lineWidth, lineCap: .round, lineJoin: .round))
                        }
                        
                        if let current = engine.currentStroke {
                            var path = Path()
                            path.addLines(current.points)
                            context.stroke(path, with: .color(current.color), style: StrokeStyle(lineWidth: current.lineWidth, lineCap: .round, lineJoin: .round))
                        }
                    }
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                engine.addPoint(value.location, color: selectedColor, lineWidth: brushSize)
                                addParticle(at: value.location)
                            }
                            .onEnded { _ in
                                engine.endStroke()
                            }
                    )
                    
                    // 3. The Outline
                    Image(systemName: category.icon)
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
                                .stroke(category.color, lineWidth: 15) // Thick Border (Match Screenshot)
                        )
                )
                .padding(30)
                
                Spacer()
                
                // BOTTOM BAR: Navigation (Match Screenshot 3)
                HStack {
                    // Back/Cancel
                    Button { dismiss() } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.red)
                    }
                    .handDrawn()
                    
                    Spacer()
                    
                    // Tools Cluster
                    HStack(spacing: 30) {
                        Button(action: { engine.undo() }) {
                            Image(systemName: "arrow.uturn.backward.circle.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.orange)
                        }
                        .handDrawn()
                        
                        Button(action: { engine.clear() }) {
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
    
    @MainActor
    func saveAndExit() {
        let renderer = ImageRenderer(content: 
            ZStack {
                CanvasLayer(color: bodyColor, icon: category.icon)
                Canvas { context, size in
                    for stroke in engine.strokes {
                        var path = Path()
                        path.addLines(stroke.points)
                        context.stroke(path, with: .color(stroke.color), style: StrokeStyle(lineWidth: stroke.lineWidth, lineCap: .round, lineJoin: .round))
                    }
                }
                Image(systemName: category.icon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(.black)
            }.frame(width: 500, height: 500)
        )
        
        if let image = renderer.uiImage {
            GalleryManager.shared.saveArtwork(
                image: image,
                category: category.name,
                profileId: ProfileManager.shared.currentProfile.id
            )
            // Reward: Add a star
            ProfileManager.shared.addStar()
        }
        dismiss()
    }
    
    func addParticle(at point: CGPoint) {
        let new = MagicParticle(pos: point, color: selectedColor)
        particles.append(new)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            particles.removeAll { $0.id == new.id }
        }
    }
    
    func createExplosion(at point: CGPoint) {
        for _ in 0..<15 { addParticle(at: point) }
    }
    
    func provideHapticFeedback() {
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
    }
}

struct CrayonButton: View {
    let color: Color
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack {
                Rectangle()
                    .fill(color)
                    .frame(width: 30, height: isSelected ? 100 : 80) // Crayon popping up
                    .overlay(
                        VStack(spacing: 0) {
                            Circle().fill(Color.white.opacity(0.3)).frame(width: 20, height: 20).padding(.top, 10)
                            Spacer()
                        }
                    )
                    .clipShape(UnevenRoundedRectangle(topLeadingRadius: 15, topTrailingRadius: 15))
                    .shadow(radius: 3)
            }
        }
        .animation(.spring(), value: isSelected)
    }
}

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

// MARK: - Magic Particles Components
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
    ColoringCanvasView(category: mockCategories[0])
}
