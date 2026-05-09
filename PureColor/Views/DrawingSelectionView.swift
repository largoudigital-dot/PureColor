import SwiftUI

struct DrawingSelectionView: View {
    let category: Category
    @Binding var path: [NavigationTarget]
    @Environment(\.dismiss) var dismiss
    
    let columns = [
        GridItem(.adaptive(minimum: 140, maximum: 180), spacing: 20)
    ]
    
    var body: some View {
        ZStack {
            // Background
            Color(red: 0.6, green: 0.9, blue: 1.0).ignoresSafeArea()
            DoodleBackgroundView().opacity(0.3).ignoresSafeArea()
            
            // Clouds
            VStack {
                HStack {
                    Image(systemName: "cloud.fill").font(.system(size: 100)).foregroundColor(.white.opacity(0.6)).offset(x: -20, y: 50)
                    Spacer()
                    Image(systemName: "cloud.fill").font(.system(size: 80)).foregroundColor(.white.opacity(0.4)).offset(x: 20, y: 150)
                }
                Spacer()
            }.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button { 
                        AudioManager.shared.playPop()
                        dismiss() 
                    } label: {
                        Image(systemName: "arrow.left.circle.fill")
                            .font(.system(size: 44))
                            .foregroundColor(.orange)
                            .shadow(radius: 5)
                    }
                    
                    Spacer()
                    
                    Text(LocalizedStringKey(category.name))
                        .font(.system(size: 38, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                        .modifier(StrokeModifier(strokeColor: category.color.opacity(0.8), lineWidth: 8))
                        .shadow(color: .black.opacity(0.2), radius: 5)
                    
                    Spacer()
                    
                    Circle().fill(Color.clear).frame(width: 44)
                }
                .padding(.horizontal, 30)
                .padding(.top, 20)
                
                ScrollView(showsIndicators: false) {
                    LazyVGrid(columns: columns, spacing: 25) {
                        ForEach(category.drawings) { drawing in
                            NavigationLink(destination: ColoringCanvasView(category: category, drawingItem: drawing)) {
                                DrawingCard(drawing: drawing, color: category.color)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(30)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

struct DrawingCard: View {
    let drawing: DrawingItem
    let color: Color
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
            
            Image(systemName: drawing.imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding(25)
                .foregroundColor(.black.opacity(0.8))
        }
        .frame(height: 160)
        .overlay(
            RoundedRectangle(cornerRadius: 25)
                .stroke(color.gradient, lineWidth: 10)
        )
        .scaleEffect(isAnimating ? 1.05 : 1.0)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
        }
    }
}
