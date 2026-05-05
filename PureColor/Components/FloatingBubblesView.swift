import SwiftUI
import Combine

struct LivingBackgroundView: View {
    var body: some View {
        ZStack {
            // Deep Dark Premium Background
            LinearGradient(colors: [Color(red: 0.05, green: 0.02, blue: 0.12), Color(red: 0.1, green: 0.05, blue: 0.2)], startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
            
            // Glowing Floating Elements
            ForEach(0..<20, id: \.self) { i in
                FloatingShape(index: i)
            }
        }
    }
}

struct FloatingShape: View {
    let index: Int
    @State private var pos = CGPoint(x: CGFloat.random(in: 0...1200), y: CGFloat.random(in: 0...900))
    @State private var scale = CGFloat.random(in: 0.3...1.2)
    @State private var opacity = Double.random(in: 0.1...0.3)
    
    var body: some View {
        Circle()
            .fill(randomColor().opacity(opacity))
            .frame(width: CGFloat.random(in: 30...100))
            .blur(radius: 20)
            .scaleEffect(scale)
            .position(pos)
            .onAppear {
                withAnimation(.linear(duration: Double.random(in: 10...20)).repeatForever(autoreverses: true)) {
                    pos.x = CGFloat.random(in: 0...1200)
                    pos.y = CGFloat.random(in: 0...900)
                }
            }
    }
    
    func randomColor() -> Color {
        let colors: [Color] = [.blue, .purple, .pink, .cyan, .orange]
        return colors.randomElement() ?? .blue
    }
}

// MARK: - Enhanced Hand Drawn Feel Modifiers
struct WobblyEffect: ViewModifier {
    @State private var angle: Double = Double.random(in: -3...3)
    @State private var scale: CGFloat = 1.0
    @State private var offset: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .rotationEffect(.degrees(angle))
            .scaleEffect(scale)
            .offset(y: offset)
            .onAppear {
                // Intense Wobble for a more "Alive" feel
                withAnimation(.easeInOut(duration: 0.15).repeatForever(autoreverses: true)) {
                    angle = Double.random(in: -2...2)
                }
                // Gentle Bounce
                withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                    scale = 1.05
                    offset = -3
                }
            }
    }
}

extension View {
    func handDrawn() -> some View {
        self.modifier(WobblyEffect())
    }
}

struct FloatingBubblesView: View {
    var body: some View {
        LivingBackgroundView()
    }
}
