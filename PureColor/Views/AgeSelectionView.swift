import SwiftUI

struct AgeSelectionView: View {
    @State private var selectedAge: AgeGroup? = nil
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Full Screen Illustrative Background
                LinearGradient(colors: [Color(red: 0.95, green: 0.98, blue: 1.0), .white], startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
                
                FloatingBubblesView()
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    // Header
                    HStack {
                        Text("PureColor")
                            .font(.system(size: 48, weight: .black, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(colors: [.blue, .purple, .pink], startPoint: .leading, endPoint: .trailing)
                            )
                            .handDrawn()
                        
                        Text("World")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(.white.opacity(0.6))
                            .offset(y: 8)
                            .handDrawn()
                        
                        Spacer()
                        
                        Button { } label: {
                            Image(systemName: "speaker.wave.3.fill")
                                .foregroundColor(.white)
                                .padding(12)
                                .background(Circle().fill(Color.purple))
                        }
                    }
                    .padding(.horizontal, 50)
                    .padding(.top, 20)
                    
                    // Horizontal Age Groups
                    HStack(spacing: 30) {
                        ForEach(AgeGroup.allCases) { age in
                            NavigationLink(destination: CategoryGridView(ageGroup: age)) {
                                AgeGroupSticker(age: age)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.bottom, 20)
                }
            }
        }
    }
}

struct AgeGroupSticker: View {
    let age: AgeGroup
    @State private var isPressed = false
    @State private var hop = false
    
    var body: some View {
        VStack(spacing: 15) {
            ZStack {
                Circle()
                    .fill(Color.white)
                    .frame(width: 120, height: 120)
                    .shadow(color: age.color.opacity(0.3), radius: 15)
                
                Image(systemName: age.icon)
                    .font(.system(size: 50))
                    .foregroundColor(age.color)
                    .handDrawn()
            }
            .offset(y: hop ? -15 : 0)
            
            VStack(spacing: 4) {
                Text(age.rawValue)
                    .font(.title2.bold())
                    .foregroundColor(.primary)
                Text(ageDesc(for: age))
                    .font(.caption.bold())
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(Color.white)
                    .shadow(color: age.color.opacity(0.5), radius: 10)
            )
        }
        .scaleEffect(isPressed ? 0.92 : 1.0)
        .onAppear {
            withAnimation(.easeInOut(duration: Double.random(in: 1.0...2.0)).repeatForever(autoreverses: true)) {
                hop = true
            }
        }
        .onLongPressGesture(minimumDuration: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
    
    func ageDesc(for age: AgeGroup) -> String {
        switch age {
        case .toddlers: return "EASY"
        case .kids: return "PLAY"
        case .bigKids: return "PRO"
        }
    }
}

struct CategoryGridView: View {
    let ageGroup: AgeGroup
    @Environment(\.dismiss) var dismiss
    
    // State for Custom Carousel
    @State private var currentIndex: Int = 0
    @State private var dragOffset: CGFloat = 0
    
    var body: some View {
        GeometryReader { geo in
            let filteredCategories = mockCategories.filter { $0.ageGroup == ageGroup }
            
            ZStack(alignment: .topLeading) {
                // Sky Background
                Color(red: 0.6, green: 0.9, blue: 1.0)
                    .ignoresSafeArea()
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                withAnimation(.interactiveSpring()) {
                                    dragOffset = value.translation.width
                                }
                            }
                            .onEnded { value in
                                let threshold: CGFloat = 50
                                let velocity = value.predictedEndLocation.x - value.location.x
                                
                                withAnimation(.spring(response: 0.35, dampingFraction: 1.0)) {
                                    if value.translation.width < -threshold || velocity < -200 {
                                        if currentIndex < filteredCategories.count - 1 {
                                            currentIndex += 1
                                            provideHapticFeedback()
                                        }
                                    } else if value.translation.width > threshold || velocity > 200 {
                                        if currentIndex > 0 {
                                            currentIndex -= 1
                                            provideHapticFeedback()
                                        }
                                    }
                                    dragOffset = 0
                                }
                            }
                    )
                
                // Decorative Parallax Clouds
                VStack {
                    HStack {
                        Image(systemName: "cloud.fill")
                            .font(.system(size: geo.size.height * 0.15))
                            .foregroundColor(.white.opacity(0.6))
                            .offset(x: -20 + (dragOffset * 0.05), y: 50)
                        Spacer()
                        Image(systemName: "cloud.fill")
                            .font(.system(size: geo.size.height * 0.1))
                            .foregroundColor(.white.opacity(0.4))
                            .offset(x: 20 + (dragOffset * 0.03), y: 20)
                    }
                    Spacer()
                }
                .ignoresSafeArea()
                .allowsHitTesting(false)
                
                // CUSTOM 3D WORLD STACK
                ZStack {
                    ForEach(0..<filteredCategories.count, id: \.self) { index in
                        let category = filteredCategories[index]
                        let relativeIndex = CGFloat(index - currentIndex)
                        let positionOffset = relativeIndex * (geo.size.width * 0.35) + dragOffset
                        let normalizedDiff = positionOffset / (geo.size.width / 2)
                        
                        SplashWorldCard(category: category, size: geo.size)
                            .frame(width: geo.size.width * 0.45)
                            .onTapGesture {
                                if index == currentIndex {
                                    WorldManager.shared.selectedCategory = category
                                } else {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 1.0)) {
                                        currentIndex = index
                                    }
                                    provideHapticFeedback()
                                }
                            }
                            .rotation3DEffect(.degrees(Double(-normalizedDiff * 40)), axis: (x: 0, y: 1, z: 0))
                            .scaleEffect(1.6 - (abs(normalizedDiff) * 0.8), anchor: .bottom)
                            .opacity(1.0 - abs(Double(normalizedDiff)) * 0.5)
                            .brightness(-Double(abs(normalizedDiff)) * 0.4)
                            .grayscale(Double(abs(normalizedDiff)) * 0.6)
                            .offset(x: positionOffset, y: pow(abs(normalizedDiff), 2.0) * 150 + (geo.size.height * 0.22))
                            .zIndex(100 - abs(Double(relativeIndex)))
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .navigationDestination(for: Category.self) { category in
                    ColoringCanvasView(category: category)
                }
                
                // FLOATING BACK BUTTON
                Button { dismiss() } label: {
                    Image(systemName: "arrow.left")
                        .font(.title.bold())
                        .padding(geo.size.height * 0.02)
                        .background(Circle().fill(Color.orange))
                        .foregroundColor(.white)
                        .shadow(radius: 5)
                }
                .padding(.leading, 30)
                .padding(.top, 20)
            }
            .onAppear {
                if !filteredCategories.isEmpty && currentIndex == 0 {
                    currentIndex = filteredCategories.count / 2
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
    
    func provideHapticFeedback() {
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
    }
}

struct SplashWorldCard: View {
    let category: Category
    let size: CGSize
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            // High-Detail Paint Splatter
            SplashShape()
                .fill(category.color)
                .frame(width: size.height * 0.45, height: size.height * 0.45) // SLIGHTLY SMALLER BASE
                .shadow(color: category.color.opacity(0.4), radius: 15)
            
            // Tilted Professional Title (NOW INSIDE ZSTACK)
            Text(category.name)
                .font(.system(size: size.height * 0.08, weight: Font.Weight.black, design: .rounded))
                .foregroundColor(.white)
                .modifier(StrokeModifier(strokeColor: category.color.opacity(0.8), lineWidth: 8))
                .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 4)
                .rotationEffect(.degrees(-5))
                .handDrawn()
                .offset(y: -size.height * 0.25) // EVEN TIGHTER TO SPLASH
            
            // Magical Decorative Elements
            ForEach(0..<8) { i in
                Image(systemName: i % 2 == 0 ? "star.fill" : "circle.fill")
                    .font(.system(size: size.height * 0.03))
                    .foregroundColor(.white.opacity(0.6))
                    .offset(x: CGFloat.random(in: -size.height * 0.25...size.height * 0.25), 
                            y: CGFloat.random(in: -size.height * 0.25...size.height * 0.25))
            }
            
            // Character Clusters
            ZStack {
                Image(systemName: category.icon)
                    .font(.system(size: size.height * 0.12))
                    .foregroundColor(.white)
                    .background(Circle().fill(Color.white).blur(radius: 10))
                    .offset(x: -size.height * 0.12, y: -size.height * 0.08)
                
                Image(systemName: category.icon)
                    .font(.system(size: size.height * 0.1))
                    .foregroundColor(.white)
                    .background(Circle().fill(Color.white).blur(radius: 10))
                    .offset(x: size.height * 0.15, y: -size.height * 0.05)
                
                Image(systemName: category.icon)
                    .font(.system(size: size.height * 0.11))
                    .foregroundColor(.white)
                    .background(Circle().fill(Color.white).blur(radius: 10))
                    .offset(x: -size.height * 0.05, y: size.height * 0.12)
                
                // Main character
                ZStack {
                    Circle().fill(Color.white).frame(width: size.height * 0.22, height: size.height * 0.22)
                    Image(systemName: category.icon)
                        .font(.system(size: size.height * 0.16))
                        .foregroundColor(category.color)
                }
                .handDrawn()
                .shadow(radius: 10)
            }
        }
        .scaleEffect(isAnimating ? 1.05 : 1.0)
        .onAppear {
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
        }
    }
}

struct SplashShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        path.move(to: CGPoint(x: w * 0.5, y: h * 0.05))
        path.addCurve(to: CGPoint(x: w * 0.8, y: h * 0.2), control1: CGPoint(x: w * 0.6, y: h * -0.1), control2: CGPoint(x: w * 0.9, y: h * 0.1))
        path.addCurve(to: CGPoint(x: w * 0.95, y: h * 0.5), control1: CGPoint(x: w * 1.1, y: h * 0.3), control2: CGPoint(x: w * 0.8, y: h * 0.4))
        path.addCurve(to: CGPoint(x: w * 0.75, y: h * 0.8), control1: CGPoint(x: w * 1.0, y: h * 0.7), control2: CGPoint(x: w * 0.9, y: h * 0.9))
        path.addCurve(to: CGPoint(x: w * 0.4, y: h * 0.95), control1: CGPoint(x: w * 0.6, y: h * 1.1), control2: CGPoint(x: w * 0.5, y: h * 0.8))
        path.addCurve(to: CGPoint(x: w * 0.1, y: h * 0.7), control1: CGPoint(x: w * 0.2, y: h * 1.0), control2: CGPoint(x: w * -0.1, y: h * 0.8))
        path.addCurve(to: CGPoint(x: w * 0.05, y: h * 0.3), control1: CGPoint(x: w * 0.1, y: h * 0.5), control2: CGPoint(x: w * -0.1, y: h * 0.4))
        path.addCurve(to: CGPoint(x: w * 0.3, y: h * 0.1), control1: CGPoint(x: w * 0.1, y: h * 0.1), control2: CGPoint(x: w * 0.2, y: h * 0.0))
        path.addCurve(to: CGPoint(x: w * 0.5, y: h * 0.05), control1: CGPoint(x: w * 0.4, y: h * 0.2), control2: CGPoint(x: w * 0.5, y: h * 0.0))
        return path
    }
}

extension View {
    func stroke(color: Color, lineWidth: CGFloat) -> some View {
        self.modifier(StrokeModifier(strokeColor: color, lineWidth: lineWidth))
    }
}

struct StrokeModifier: ViewModifier {
    var strokeColor: Color
    var lineWidth: CGFloat
    func body(content: Content) -> some View {
        content
            .shadow(color: strokeColor, radius: 0, x: lineWidth, y: 0)
            .shadow(color: strokeColor, radius: 0, x: -lineWidth, y: 0)
            .shadow(color: strokeColor, radius: 0, x: 0, y: lineWidth)
            .shadow(color: strokeColor, radius: 0, x: 0, y: -lineWidth)
    }
}

#Preview {
    AgeSelectionView()
}
