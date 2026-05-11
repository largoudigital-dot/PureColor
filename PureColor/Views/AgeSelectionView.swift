import SwiftUI
import Combine

// Professional Navigation Targets
enum NavigationTarget: Hashable {
    case categoryWheel(AgeGroup)
    case drawingGrid(Category)
}

struct AgeSelectionView: View {
    @StateObject private var profileManager = ProfileManager.shared
    @StateObject private var galleryManager = GalleryManager.shared
    
    @State private var path = [NavigationTarget]()
    @State private var showParentalGate = false
    @State private var pendingAction: (() -> Void)? = nil
    @State private var showGallery = false
    @State private var showAddProfile = false
    @State private var showParentSettings = false
    
    @AppStorage("soundEnabled") private var soundEnabled = true
    @AppStorage("musicEnabled") private var musicEnabled = true
    @State private var timerSecondsRemaining: Int? = nil
    @State private var timerActive = false
    @State private var showDailyReward = false
    @State private var showMagicBoxSurprise = false
    @State private var showTimerPicker = false
    @State private var showTimesUp = false
    @State private var showProfilePicker = false
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        NavigationStack(path: $path) {
            GeometryReader { geo in
                let isIPad = UIDevice.current.userInterfaceIdiom == .pad
                let isLandscape = geo.size.width > geo.size.height
                
                ZStack {
                    // 1. Deep Premium Background
                    LinearGradient(colors: [Color(red: 0.98, green: 0.98, blue: 1.0), Color(red: 0.92, green: 0.96, blue: 1.0)], startPoint: .topLeading, endPoint: .bottomTrailing)
                        .ignoresSafeArea()
                    
                    // Animated Bubbles
                    HomeLivingBackground()
                        .opacity(0.4)
                    
                    let baseSize = isLandscape ? geo.size.height : geo.size.width
                    let buttonSize = min(max(baseSize * 0.14, 55), isIPad ? 90 : 70)
                    let sideSpacing = baseSize * 0.05
                    
                    // 2. MAIN CENTER CONTENT
                    VStack(spacing: isLandscape ? geo.size.height * 0.02 : geo.size.height * 0.05) {
                        // Logo/Title
                        VStack(spacing: 4) {
                            Text(LocalizedStringKey("PureColor"))
                                .font(.system(size: isLandscape ? baseSize * 0.12 : baseSize * 0.15, weight: .black, design: .rounded))
                                .foregroundStyle(
                                    LinearGradient(colors: [.blue, .purple, .pink], startPoint: .leading, endPoint: .trailing)
                                )
                                .shadow(color: .blue.opacity(0.15), radius: 10, y: 5)
                            
                            if profileManager.currentProfile.ageGroup == nil {
                                Text(LocalizedStringKey("CREATIVE WORLD FOR EVERYONE"))
                                    .font(.system(size: baseSize * 0.03, weight: .black, design: .rounded))
                                    .foregroundColor(.blue.opacity(0.4))
                                    .tracking(4)
                            }
                        }
                        .padding(.top, isLandscape ? geo.size.height * 0.05 : geo.size.height * 0.1)
                        
                        if let childAge = profileManager.currentProfile.ageGroup {
                            // Active Profile View
                            VStack(spacing: geo.size.height * 0.05) {
                                Text(String(format: NSLocalizedString("Hello, %@!", comment: ""), profileManager.currentProfile.name))
                                    .font(.system(size: baseSize * 0.06, weight: .bold, design: .rounded))
                                    .foregroundColor(.black.opacity(0.6))
                                
                                Button {
                                    AudioManager.shared.playPop()
                                    path.append(.categoryWheel(childAge))
                                } label: {
                                    VStack(spacing: geo.size.height * 0.03) {
                                        AgeWorldCard(age: childAge, isIPad: isIPad, isLandscape: isLandscape, dynamicSize: baseSize * 0.4)
                                            .scaleEffect(1.1)
                                        
                                        Text(LocalizedStringKey("TAP TO PLAY"))
                                            .font(.system(size: baseSize * 0.05, weight: .black, design: .rounded))
                                            .foregroundColor(.white)
                                            .padding(.horizontal, baseSize * 0.12)
                                            .padding(.vertical, baseSize * 0.03)
                                            .background(
                                                Capsule()
                                                    .fill(childAge.color.gradient)
                                                    .shadow(color: childAge.color.opacity(0.4), radius: 15, y: 8)
                                            )
                                    }
                                }
                                
                                Button(LocalizedStringKey("Switch Profile")) {
                                    withAnimation { showProfilePicker = true }
                                }
                                .font(.system(size: baseSize * 0.035, weight: .black, design: .rounded))
                                .foregroundColor(.blue)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(Capsule().fill(Color.blue.opacity(0.08)))
                            }
                        } else {
                            // Age Selection Grid
                            HStack(spacing: baseSize * 0.03) {
                                ForEach(AgeGroup.allCases) { age in
                                    Button {
                                        AudioManager.shared.playPop()
                                        path.append(.categoryWheel(age))
                                    } label: {
                                        AgeWorldCard(age: age, isIPad: isIPad, isLandscape: isLandscape, dynamicSize: baseSize * 0.28)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding(.horizontal, 20)
                            
                            Button {
                                pendingAction = { showAddProfile = true }
                                showParentalGate = true
                            } label: {
                                HStack(spacing: 12) {
                                    Image(systemName: "plus.circle.fill")
                                    Text(LocalizedStringKey("Create Artist Profile"))
                                }
                                .font(.system(size: baseSize * 0.045, weight: .black, design: .rounded))
                                .foregroundColor(.white)
                                .padding(.horizontal, baseSize * 0.1)
                                .padding(.vertical, baseSize * 0.04)
                                .background(
                                    Capsule()
                                        .fill(LinearGradient(colors: [.blue, .cyan], startPoint: .leading, endPoint: .trailing))
                                        .shadow(color: .blue.opacity(0.3), radius: 10, y: 5)
                                )
                            }
                            .padding(.top, 20)
                        }
                        Spacer()
                    }
                    
                    // 3. GLASSMORPHIC SIDE CONTROLS (DOCKED TO EDGES, RESPONSIVE)
                    HStack(alignment: .top) {
                        // Left Side Dock
                        VStack(spacing: sideSpacing) {
                            ControlBarGroup(isLeft: true, safeArea: geo.safeAreaInsets.leading) {
                                HeaderCircleButton(icon: profileManager.currentProfile.avatar, color: .blue, size: buttonSize) {
                                    withAnimation(.spring()) { showProfilePicker = true }
                                }
                                HeaderCircleButton(icon: "photo.on.rectangle.angled", color: .green, size: buttonSize) { 
                                    AudioManager.shared.playPop()
                                    showGallery = true 
                                }
                                HeaderCircleButton(icon: "archivebox.fill", color: .orange, size: buttonSize) {
                                    withAnimation(.spring()) { showMagicBoxSurprise = true }
                                }
                            }
                            
                            ControlBarGroup(isLeft: true, safeArea: geo.safeAreaInsets.leading) {
                                HeaderCircleButton(icon: "star.bubble.fill", color: .yellow, size: buttonSize) {
                                    pendingAction = {
                                        if let url = URL(string: "https://apps.apple.com/app/idYOUR_APP_ID?action=write-review") {
                                            UIApplication.shared.open(url)
                                        }
                                    }
                                    showParentalGate = true
                                }
                            }
                            Spacer()
                        }
                        .padding(.top, isLandscape ? geo.size.height * 0.05 : geo.size.height * 0.1)
                        
                        Spacer()
                        
                        // Right Side Dock
                        VStack(spacing: sideSpacing) {
                            ControlBarGroup(isLeft: false, safeArea: geo.safeAreaInsets.trailing) {
                                HeaderCircleButton(icon: "gearshape.fill", color: .gray, size: buttonSize) {
                                    pendingAction = { showParentSettings = true }
                                    showParentalGate = true
                                }
                                HeaderCircleButton(icon: "timer", color: timerSecondsRemaining != nil ? .red : .orange, size: buttonSize) {
                                    pendingAction = { showTimerPicker = true }
                                    showParentalGate = true
                                }
                            }
                            
                            ControlBarGroup(isLeft: false, safeArea: geo.safeAreaInsets.trailing) {
                                HeaderCircleButton(icon: musicEnabled ? "music.note" : "music.note.list", color: .purple, size: buttonSize) { 
                                    musicEnabled.toggle() 
                                    AudioManager.shared.playPop()
                                }
                                HeaderCircleButton(icon: soundEnabled ? "speaker.wave.3.fill" : "speaker.slash.fill", color: .pink, size: buttonSize) { 
                                    soundEnabled.toggle() 
                                    AudioManager.shared.playPop()
                                }
                            }
                            
                            if let remaining = timerSecondsRemaining {
                                TimerPill(seconds: remaining)
                                    .scaleEffect(buttonSize / 65)
                                    .padding(.trailing, 10 + geo.safeAreaInsets.trailing)
                            }
                            
                            Spacer()
                        }
                        .padding(.top, isLandscape ? geo.size.height * 0.05 : geo.size.height * 0.1)
                    }
                    .ignoresSafeArea()
                    
                    if showParentSettings {
                        ParentSettingsView(isPresented: $showParentSettings, soundEnabled: $soundEnabled, musicEnabled: $musicEnabled, timerSecondsRemaining: $timerSecondsRemaining, timerActive: $timerActive)
                            .transition(.move(edge: .trailing).combined(with: .opacity))
                    }
                    if showMagicBoxSurprise { MagicBoxSurpriseView(isPresented: $showMagicBoxSurprise) }
                    if showTimerPicker { TimerSelectionPopup(isPresented: $showTimerPicker, timerSecondsRemaining: $timerSecondsRemaining, timerActive: $timerActive) }
                    if showProfilePicker { ProfileSelectionPopup(isPresented: $showProfilePicker) }
                }
                .navigationDestination(for: NavigationTarget.self) { target in
                    switch target {
                    case .categoryWheel(let age):
                        CategoryGridView(ageGroup: age, path: $path)
                    case .drawingGrid(let category):
                        DrawingSelectionView(category: category, path: $path)
                    }
                }
                
                if showDailyReward { DailyRewardPopup(isPresented: $showDailyReward) }
                if showAddProfile { AddProfilePopup(isPresented: $showAddProfile, isLandscape: isLandscape) }
            }
            .fullScreenCover(isPresented: $showParentalGate) {
                ParentalGateView { pendingAction?() }
                .presentationBackground(.clear)
            }
            .fullScreenCover(isPresented: $showGallery) { GalleryView() }
            .onAppear { checkDailyReward() }
            .onReceive(timer) { _ in
                if timerActive, let remaining = timerSecondsRemaining {
                    if remaining > 0 {
                        timerSecondsRemaining = remaining - 1
                    } else if !showTimesUp {
                        withAnimation { showTimesUp = true }
                        timerActive = false
                    }
                }
            }
            .fullScreenCover(isPresented: $showTimesUp) {
                TimesUpView(isPresented: $showTimesUp, timerSecondsRemaining: $timerSecondsRemaining, timerActive: $timerActive)
            }
        }
    }
    
    func timeString(from seconds: Int) -> String {
        let h = seconds / 3600; let m = (seconds % 3600) / 60; let s = seconds % 60
        if h > 0 { return String(format: "%d:%02d:%02d", h, m, s) }
        return String(format: "%02d:%02d", m, s)
    }
    
    func checkDailyReward() {
        let lastClaim = profileManager.currentProfile.lastDailyRewardClaimed ?? Date.distantPast
        if !Calendar.current.isDateInToday(lastClaim) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { withAnimation(.spring()) { showDailyReward = true } }
        }
    }
}

// MARK: - PREMIUM COMPONENTS
struct HomeLivingBackground: View {
    @State private var isAnimating = false
    var body: some View {
        ZStack {
            ForEach(0..<12) { i in
                Circle()
                    .fill(Color.blue.opacity(0.1))
                    .frame(width: CGFloat.random(in: 100...300))
                    .position(
                        x: isAnimating ? CGFloat.random(in: 0...1000) : CGFloat.random(in: 0...1000),
                        y: isAnimating ? CGFloat.random(in: 0...1000) : CGFloat.random(in: 0...1000)
                    )
                    .blur(radius: 60)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 10).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
        }
    }
}

struct ControlBarGroup<Content: View>: View {
    let isLeft: Bool
    let safeArea: CGFloat
    let content: Content
    init(isLeft: Bool, safeArea: CGFloat, @ViewBuilder content: () -> Content) { 
        self.isLeft = isLeft
        self.safeArea = safeArea
        self.content = content() 
    }
    var body: some View {
        VStack(spacing: 20) { content }
            .padding(.vertical, 15)
            .padding(isLeft ? .leading : .trailing, 10 + safeArea)
            .padding(isLeft ? .trailing : .leading, 10)
            .background(
                UnevenRoundedRectangle(
                    topLeadingRadius: isLeft ? 0 : 28,
                    bottomLeadingRadius: isLeft ? 0 : 28,
                    bottomTrailingRadius: isLeft ? 28 : 0,
                    topTrailingRadius: isLeft ? 28 : 0
                )
                .fill(.white.opacity(0.4))
                .background(.ultraThinMaterial)
                .overlay(
                    UnevenRoundedRectangle(
                        topLeadingRadius: isLeft ? 0 : 28,
                        bottomLeadingRadius: isLeft ? 0 : 28,
                        bottomTrailingRadius: isLeft ? 28 : 0,
                        topTrailingRadius: isLeft ? 28 : 0
                    )
                    .stroke(.white.opacity(0.4), lineWidth: 1)
                )
            )
            .shadow(color: .black.opacity(0.04), radius: 10, y: 5)
    }
}

struct TimerPill: View {
    let seconds: Int
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "timer")
                .foregroundColor(.red)
            Text(timeString(from: seconds))
                .font(.system(.caption, design: .monospaced).bold())
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Capsule().fill(.white).shadow(color: .black.opacity(0.1), radius: 5))
    }
    func timeString(from seconds: Int) -> String {
        let m = (seconds % 3600) / 60; let s = seconds % 60
        return String(format: "%02d:%02d", m, s)
    }
}

struct AgeWorldCard: View {
    let age: AgeGroup; let isIPad: Bool; let isLandscape: Bool; var dynamicSize: CGFloat = 130; @State private var isFloating = false
    var body: some View {
        let cardSize: CGFloat = dynamicSize
        VStack(spacing: cardSize * 0.08) {
            ZStack {
                // Outer Glow
                Circle()
                    .fill(age.color.opacity(0.2))
                    .frame(width: cardSize * 0.95, height: cardSize * 0.95)
                    .blur(radius: cardSize * 0.1)
                
                // Main Circle
                Circle()
                    .fill(LinearGradient(colors: [.white, Color(white: 0.98)], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: cardSize * 0.85, height: cardSize * 0.85)
                    .shadow(color: age.color.opacity(0.25), radius: cardSize * 0.1, x: 0, y: cardSize * 0.08)
                
                // Content
                VStack(spacing: 5) {
                    Image(systemName: age.icon)
                        .font(.system(size: cardSize * 0.35, weight: .bold))
                        .foregroundStyle(LinearGradient(colors: [age.color, age.color.opacity(0.7)], startPoint: .top, endPoint: .bottom))
                        .handDrawn()
                }
            }
            .offset(y: isFloating ? -cardSize * 0.05 : cardSize * 0.05)
            
            VStack(spacing: 4) {
                Text(LocalizedStringKey(age.rawValue))
                    .font(.system(size: cardSize * 0.15, weight: .black, design: .rounded))
                    .foregroundColor(.black)
                
                Text(LocalizedStringKey(age.subtitleKey))
                    .font(.system(size: cardSize * 0.1, weight: .black, design: .rounded))
                    .foregroundColor(age.color)
                    .padding(.horizontal, cardSize * 0.1)
                    .padding(.vertical, cardSize * 0.03)
                    .background(age.color.opacity(0.1))
                    .cornerRadius(cardSize * 0.05)
            }
        }
        .frame(width: cardSize)
        .onAppear {
            withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
                isFloating = true
            }
        }
    }
}

struct CategoryGridView: View {
    let ageGroup: AgeGroup; @Binding var path: [NavigationTarget]; @Environment(\.dismiss) var dismiss; @State private var currentIndex: Int = 0; @State private var dragOffset: CGFloat = 0
    var body: some View {
        GeometryReader { geo in
            let filteredCategories = mockCategories.filter { $0.ageGroup == ageGroup }
            ZStack(alignment: .topLeading) {
                Color(red: 0.6, green: 0.9, blue: 1.0).ignoresSafeArea().contentShape(Rectangle()).gesture(DragGesture().onChanged { dragOffset = $0.translation.width }.onEnded { value in
                    let threshold: CGFloat = 50; let velocity = value.predictedEndLocation.x - value.location.x; withAnimation(.spring(response: 0.35, dampingFraction: 1.0)) { if value.translation.width < -threshold || velocity < -200 { if currentIndex < filteredCategories.count - 1 { currentIndex += 1; provideHapticFeedback() } } else if value.translation.width > threshold || velocity > 200 { if currentIndex > 0 { currentIndex -= 1; provideHapticFeedback() } }; dragOffset = 0 }
                })
                VStack { HStack { Image(systemName: "cloud.fill").font(.system(size: geo.size.height * 0.15)).foregroundColor(.white.opacity(0.6)).offset(x: -20 + (dragOffset * 0.05), y: 50); Spacer(); Image(systemName: "cloud.fill").font(.system(size: geo.size.height * 0.1)).foregroundColor(.white.opacity(0.4)).offset(x: 20 + (dragOffset * 0.03), y: 20) }; Spacer() }.ignoresSafeArea().allowsHitTesting(false)
                ZStack {
                    ForEach(0..<filteredCategories.count, id: \.self) { index in
                        let category = filteredCategories[index]; let relativeIndex = CGFloat(index - currentIndex); let positionOffset = relativeIndex * (geo.size.width * 0.35) + dragOffset; let normalizedDiff = positionOffset / (geo.size.width / 2)
                        SplashWorldCard(category: category, size: geo.size).frame(width: geo.size.width * 0.45).onTapGesture { if index == currentIndex { AudioManager.shared.playPop(); path.append(.drawingGrid(category)) } else { withAnimation(.spring(response: 0.3, dampingFraction: 1.0)) { currentIndex = index }; provideHapticFeedback() } }.rotation3DEffect(.degrees(Double(-normalizedDiff * 40)), axis: (x: 0, y: 1, z: 0)).scaleEffect(1.6 - (abs(normalizedDiff) * 0.8), anchor: .bottom).opacity(1.0 - abs(Double(normalizedDiff)) * 0.5).brightness(-Double(abs(normalizedDiff)) * 0.4).grayscale(Double(abs(normalizedDiff)) * 0.6).offset(x: positionOffset, y: pow(abs(normalizedDiff), 2.0) * 150 + (geo.size.height * 0.22)).zIndex(100 - abs(Double(relativeIndex)))
                    }
                }.frame(maxWidth: .infinity, maxHeight: .infinity)
                Button { dismiss() } label: { Image(systemName: "arrow.left").font(.title.bold()).padding(geo.size.height * 0.02).background(Circle().fill(Color.orange)).foregroundColor(.white).shadow(radius: 5) }.padding(.leading, 30).padding(.top, 20)
            }.onAppear { if !filteredCategories.isEmpty && currentIndex == 0 { currentIndex = filteredCategories.count / 2 } }
        }.navigationBarBackButtonHidden(true)
    }
    func provideHapticFeedback() { let impact = UIImpactFeedbackGenerator(style: .medium); impact.impactOccurred() }
}

struct SplashWorldCard: View {
    let category: Category; let size: CGSize; @State private var isAnimating = false
    var body: some View {
        ZStack {
            SplashShape().fill(category.color).frame(width: size.height * 0.45, height: size.height * 0.45).shadow(color: category.color.opacity(0.4), radius: 15)
            Text(LocalizedStringKey(category.name)).font(.system(size: size.height * 0.08, weight: Font.Weight.black, design: .rounded)).foregroundColor(.white).modifier(StrokeModifier(strokeColor: category.color.opacity(0.8), lineWidth: 8)).shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 4).rotationEffect(.degrees(-5)).handDrawn().offset(y: -size.height * 0.25)
            ForEach(0..<8) { i in Image(systemName: i % 2 == 0 ? "star.fill" : "circle.fill").font(.system(size: size.height * 0.03)).foregroundColor(.white.opacity(0.6)).offset(x: CGFloat.random(in: -size.height * 0.25...size.height * 0.25), y: CGFloat.random(in: -size.height * 0.25...size.height * 0.25)) }
            ZStack { Image(systemName: category.icon).font(.system(size: size.height * 0.12)).foregroundColor(.white).background(Circle().fill(Color.white).blur(radius: 10)).offset(x: -size.height * 0.12, y: -size.height * 0.08); Image(systemName: category.icon).font(.system(size: size.height * 0.10)).foregroundColor(.white).background(Circle().fill(Color.white).blur(radius: 10)).offset(x: size.height * 0.15, y: -size.height * 0.05); Image(systemName: category.icon).font(.system(size: size.height * 0.11)).foregroundColor(.white).background(Circle().fill(Color.white).blur(radius: 10)).offset(x: -size.height * 0.05, y: size.height * 0.12); ZStack { Circle().fill(Color.white).frame(width: size.height * 0.22, height: size.height * 0.22); Image(systemName: category.icon).font(.system(size: size.height * 0.16)).foregroundColor(category.color) }.handDrawn().shadow(radius: 10) }
        }.scaleEffect(isAnimating ? 1.05 : 1.0).onAppear { withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) { isAnimating = true } }
    }
}

struct SplashShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path(); let w = rect.width, h = rect.height
        path.move(to: CGPoint(x: w * 0.5, y: h * 0.05)); path.addCurve(to: CGPoint(x: w * 0.8, y: h * 0.2), control1: CGPoint(x: w * 0.6, y: h * -0.1), control2: CGPoint(x: w * 0.9, y: h * 0.1)); path.addCurve(to: CGPoint(x: w * 0.95, y: h * 0.5), control1: CGPoint(x: w * 1.1, y: h * 0.3), control2: CGPoint(x: w * 0.8, y: h * 0.4)); path.addCurve(to: CGPoint(x: w * 0.75, y: h * 0.8), control1: CGPoint(x: w * 1.0, y: h * 0.7), control2: CGPoint(x: w * 0.9, y: h * 0.9)); path.addCurve(to: CGPoint(x: w * 0.4, y: h * 0.95), control1: CGPoint(x: w * 0.6, y: h * 1.1), control2: CGPoint(x: w * 0.5, y: h * 0.8)); path.addCurve(to: CGPoint(x: w * 0.1, y: h * 0.7), control1: CGPoint(x: w * 0.2, y: h * 1.0), control2: CGPoint(x: w * -0.1, y: h * 0.8)); path.addCurve(to: CGPoint(x: w * 0.05, y: h * 0.3), control1: CGPoint(x: w * 0.1, y: h * 0.5), control2: CGPoint(x: w * -0.1, y: h * 0.4)); path.addCurve(to: CGPoint(x: w * 0.3, y: h * 0.1), control1: CGPoint(x: w * 0.1, y: h * 0.1), control2: CGPoint(x: w * 0.2, y: h * 0.0)); path.addCurve(to: CGPoint(x: w * 0.5, y: h * 0.05), control1: CGPoint(x: w * 0.4, y: h * 0.2), control2: CGPoint(x: w * 0.5, y: h * 0.0)); return path
    }
}

struct StrokeModifier: ViewModifier {
    var strokeColor: Color, lineWidth: CGFloat
    func body(content: Content) -> some View { content.shadow(color: strokeColor, radius: 0, x: lineWidth, y: 0).shadow(color: strokeColor, radius: 0, x: -lineWidth, y: 0).shadow(color: strokeColor, radius: 0, x: 0, y: lineWidth).shadow(color: strokeColor, radius: 0, x: 0, y: -lineWidth) }
}

struct ParentSettingsView: View {
    @Binding var isPresented: Bool; @Binding var soundEnabled: Bool; @Binding var musicEnabled: Bool; @Binding var timerSecondsRemaining: Int?; @Binding var timerActive: Bool
    @EnvironmentObject var languageManager: LanguageManager
    var body: some View {
        ZStack {
            Color.black.opacity(0.4).ignoresSafeArea().onTapGesture { isPresented = false }
            VStack(spacing: 20) {
                Text(LocalizedStringKey("App Settings")).font(.title2.weight(.black)).foregroundColor(.black)
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 15) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(LocalizedStringKey("Language")).font(.headline).foregroundColor(.gray)
                            Menu {
                                Picker("Language", selection: $languageManager.selectedLanguage) {
                                    ForEach(AppLanguage.allCases) { lang in
                                        Text(lang.name).tag(lang)
                                    }
                                }
                            } label: {
                                HStack {
                                    Text(languageManager.selectedLanguage.name).font(.body.bold())
                                    Spacer()
                                    Image(systemName: "chevron.up.chevron.down").font(.caption)
                                }
                                .padding()
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(12)
                                .foregroundColor(.blue)
                            }
                        }
                        .padding(10)
                        .background(Color.gray.opacity(0.05))
                        .cornerRadius(12)
                        Group { Toggle(LocalizedStringKey("Sound Effects"), isOn: $soundEnabled); Toggle(LocalizedStringKey("Background Music"), isOn: $musicEnabled) }.padding(10).background(Color.gray.opacity(0.05)).cornerRadius(12)
                        Divider()
                        VStack(spacing: 12) { SettingsRow(icon: "questionmark.circle.fill", title: "Support", color: .blue); SettingsRow(icon: "lock.shield.fill", title: "Privacy Policy", color: .green); SettingsRow(icon: "doc.text.fill", title: "Terms of Use", color: .orange) }
                    }
                }.frame(maxHeight: 250)
                Button(LocalizedStringKey("Done")) { withAnimation { isPresented = false } }.font(.headline).foregroundColor(.white).padding(.horizontal, 50).padding(.vertical, 12).background(Capsule().fill(Color.blue))
            }.padding(25).background(RoundedRectangle(cornerRadius: 30).fill(Color.white)).padding(30).frame(maxWidth: 400)
        }
    }
}

struct SettingsRow: View {
    let icon: String; let title: String; let color: Color
    var body: some View { HStack { Image(systemName: icon).foregroundColor(color).font(.title3); Text(LocalizedStringKey(title)).font(.body.weight(.medium)); Spacer(); Image(systemName: "chevron.right").font(.caption).foregroundColor(.gray) }.padding(12).background(Color.gray.opacity(0.05)).cornerRadius(12) }
}

struct DailyRewardPopup: View {
    @Binding var isPresented: Bool
    @StateObject private var profileManager = ProfileManager.shared
    var body: some View {
        GeometryReader { geo in
            let isLandscape = geo.size.width > geo.size.height
            ZStack {
                Color.black.opacity(0.8).ignoresSafeArea()
                VStack(spacing: isLandscape ? 12 : 25) {
                    Text(LocalizedStringKey("Daily Prize!")).font(.system(size: isLandscape ? 28 : 32, weight: .black, design: .rounded)).foregroundColor(.white)
                    ZStack { Circle().fill(Color.yellow.gradient).frame(width: isLandscape ? 100 : 150, height: isLandscape ? 100 : 150); Image(systemName: "star.fill").font(.system(size: isLandscape ? 50 : 80)).foregroundColor(.white).shadow(radius: 10) }
                    Text(LocalizedStringKey("You earned 5 Stars!")).font(.system(size: isLandscape ? 18 : 22, weight: .bold)).foregroundColor(.white)
                    Button {
                        AudioManager.shared.playSuccess()
                        profileManager.currentProfile.stars += 5
                        profileManager.currentProfile.lastDailyRewardClaimed = Date()
                        profileManager.save()
                        withAnimation { isPresented = false }
                    } label: { Text(LocalizedStringKey("Collect")).font(.headline).foregroundColor(.white).padding(.horizontal, 40).padding(.vertical, isLandscape ? 12 : 15).background(Capsule().fill(Color.blue.gradient)) }
                }
                .padding(isLandscape ? 25 : 40)
                .background(RoundedRectangle(cornerRadius: 30).fill(Color.white.opacity(0.1)).background(.ultraThinMaterial))
                .cornerRadius(30).padding(isLandscape ? 20 : 40).frame(maxWidth: 450)
            }.frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

struct TimerSelectionPopup: View {
    @Binding var isPresented: Bool; @Binding var timerSecondsRemaining: Int?; @Binding var timerActive: Bool
    var body: some View { ZStack { Rectangle().fill(.ultraThinMaterial).overlay(Color.black.opacity(0.2)).ignoresSafeArea().onTapGesture { isPresented = false }; VStack(spacing: 25) { Text(LocalizedStringKey("Set Screen Time")).font(.system(size: 24, weight: .black, design: .rounded)); HStack(spacing: 15) { ForEach([20, 60, 120], id: \.self) { mins in Button { timerSecondsRemaining = mins * 60; timerActive = true; isPresented = false } label: { VStack { Text("\(mins >= 60 ? mins/60 : mins)").font(.system(size: 28, weight: .black)); Text(LocalizedStringKey(mins >= 60 ? "HOUR" : "MIN")).font(.caption.bold()) }.frame(width: 80, height: 90).background(RoundedRectangle(cornerRadius: 20).fill(timerSecondsRemaining == mins * 60 ? Color.blue : Color.white)).foregroundColor(timerSecondsRemaining == mins * 60 ? .white : .blue) } } }; Button(LocalizedStringKey("Turn Off")) { timerSecondsRemaining = nil; timerActive = false; isPresented = false }.foregroundColor(.red) }.padding(30).background(RoundedRectangle(cornerRadius: 35).fill(Color.white)).frame(maxWidth: 400).padding(20) } }
}

struct TimesUpView: View {
    @Binding var isPresented: Bool; @Binding var timerSecondsRemaining: Int?; @Binding var timerActive: Bool; @State private var showParentalGate = false
    var body: some View { ZStack { Color.white.ignoresSafeArea(); HomeLivingBackground().opacity(0.3); VStack(spacing: 30) { ZStack { Circle().fill(Color.orange.opacity(0.1)).frame(width: 200, height: 200); Image(systemName: "moon.stars.fill").font(.system(size: 100)).foregroundColor(.orange) }; Text(LocalizedStringKey("Time to Rest!")).font(.system(size: 40, weight: .black, design: .rounded)); Button { showParentalGate = true } label: { Text(LocalizedStringKey("Parents Only")).padding(.horizontal, 40).padding(.vertical, 15).background(Capsule().fill(Color.blue)).foregroundColor(.white) } } }.fullScreenCover(isPresented: $showParentalGate) { ParentalGateView { timerSecondsRemaining = nil; timerActive = false; isPresented = false }.presentationBackground(.clear) } }
}

struct ProfileSelectionPopup: View {
    @Binding var isPresented: Bool; @StateObject private var profileManager = ProfileManager.shared; @State private var showParentalGate = false; @State private var profileToDelete: Int? = nil
    var body: some View {
        ZStack {
            Rectangle().fill(.ultraThinMaterial).overlay(Color.black.opacity(0.2)).ignoresSafeArea().onTapGesture { isPresented = false }
            VStack(spacing: 20) {
                Text(LocalizedStringKey("Who is coloring?")).font(.system(size: 24, weight: .black, design: .rounded))
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 25) {
                        ForEach(0..<profileManager.profiles.count, id: \.self) { i in
                            VStack(spacing: 12) {
                                ZStack(alignment: .topTrailing) {
                                    Button { profileManager.currentProfileIndex = i; withAnimation { isPresented = false }; AudioManager.shared.playPop() } label: {
                                        ZStack { Circle().fill(profileManager.currentProfileIndex == i ? Color.blue.gradient : Color.white.gradient).frame(width: 90, height: 90).shadow(color: .black.opacity(0.1), radius: 5); Image(systemName: profileManager.profiles[i].avatar).font(.system(size: 40)).foregroundColor(profileManager.currentProfileIndex == i ? .white : .blue) }.overlay(Circle().stroke(Color.blue.opacity(0.2), lineWidth: profileManager.currentProfileIndex == i ? 0 : 2))
                                    }
                                    if profileManager.profiles.count > 1 {
                                        Button { profileToDelete = i; showParentalGate = true } label: { Image(systemName: "trash.fill").font(.system(size: 12)).foregroundColor(.white).padding(8).background(Circle().fill(Color.red)).shadow(radius: 2) }.offset(x: 5, y: -5)
                                    }
                                }
                                Text(LocalizedStringKey(profileManager.profiles[i].name)).font(.system(size: 14, weight: .black, design: .rounded)).foregroundColor(.black.opacity(0.7))
                            }
                        }
                    }.padding(.horizontal, 30).padding(.vertical, 10)
                }
                Button(LocalizedStringKey("Close")) { withAnimation { isPresented = false } }.font(.headline.bold()).foregroundColor(.gray).padding(.top, 10)
            }.padding(.vertical, 30).background(RoundedRectangle(cornerRadius: 35).fill(Color.white)).padding(30).frame(maxWidth: 550)
        }
        .fullScreenCover(isPresented: $showParentalGate) { ParentalGateView { if let index = profileToDelete { profileManager.profiles.remove(at: index); if profileManager.currentProfileIndex >= profileManager.profiles.count { profileManager.currentProfileIndex = profileManager.profiles.count - 1 }; profileManager.save(); AudioManager.shared.playPop(); profileToDelete = nil } }.presentationBackground(.clear) }
    }
}

struct AddProfilePopup: View {
    @Binding var isPresented: Bool; let isLandscape: Bool; @StateObject private var profileManager = ProfileManager.shared; @State private var selectedAge: AgeGroup = .toddlers; @State private var selectedAvatarIndex = 0
    let avatars = [(icon: "bolt.shield.fill", name: "Super Hero"), (icon: "crown.fill", name: "Princess"), (icon: "figure.robot", name: "Robot"), (icon: "pawprint.fill", name: "Animal"), (icon: "star.fill", name: "Star"), (icon: "heart.fill", name: "Happy")]
    var body: some View {
        ZStack {
            Color.black.opacity(0.7).ignoresSafeArea()
            VStack(spacing: isLandscape ? 10 : 20) {
                Text(LocalizedStringKey("Choose Your Hero!")).font(.system(size: isLandscape ? 22 : 28, weight: .black, design: .rounded)).padding(.top, isLandscape ? 5 : 10)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: isLandscape ? 15 : 25) {
                        ForEach(0..<avatars.count, id: \.self) { index in
                            Button { selectedAvatarIndex = index; AudioManager.shared.playPop() } label: {
                                VStack(spacing: 5) { ZStack { Circle().fill(selectedAvatarIndex == index ? Color.blue.gradient : Color.gray.opacity(0.15).gradient).frame(width: isLandscape ? 60 : 85, height: isLandscape ? 60 : 85); Image(systemName: avatars[index].icon).font(.system(size: isLandscape ? 28 : 40)).foregroundColor(selectedAvatarIndex == index ? .white : .gray.opacity(0.6)) }.shadow(color: selectedAvatarIndex == index ? .blue.opacity(0.3) : .clear, radius: 8); Text(LocalizedStringKey(avatars[index].name)).font(.system(size: isLandscape ? 10 : 12, weight: .bold)).foregroundColor(selectedAvatarIndex == index ? .blue : .gray) }
                            }
                        }
                    }.padding(.horizontal, 20)
                }.frame(height: isLandscape ? 100 : 130)
                Divider().padding(.horizontal, 60)
                Text(LocalizedStringKey("How old are you?")).font(.system(size: isLandscape ? 16 : 20, weight: .bold))
                HStack(spacing: 12) {
                    ForEach(AgeGroup.allCases) { age in
                        Button { selectedAge = age; AudioManager.shared.playPop() } label: { Text(LocalizedStringKey(age.rawValue)).font(.system(size: isLandscape ? 14 : 16, weight: .black)).padding(.horizontal, isLandscape ? 15 : 20).padding(.vertical, isLandscape ? 8 : 12).background(selectedAge == age ? age.color.gradient : Color.gray.opacity(0.1).gradient).foregroundColor(selectedAge == age ? .white : .gray).cornerRadius(15) }
                    }
                }
                Button { let newP = UserProfile(id: UUID(), name: avatars[selectedAvatarIndex].name, avatar: avatars[selectedAvatarIndex].icon, ageGroup: selectedAge, stars: 0, lastDailyRewardClaimed: nil, collectedStickers: [], completedDrawings: [], inProgressDrawings: []); profileManager.profiles.append(newP); profileManager.currentProfileIndex = profileManager.profiles.count - 1; profileManager.save(); AudioManager.shared.playSuccess(); isPresented = false } label: { Text(LocalizedStringKey("START COLORING!")).font(.system(size: isLandscape ? 16 : 20, weight: .black)).foregroundColor(.white).padding(.horizontal, isLandscape ? 40 : 50).padding(.vertical, isLandscape ? 12 : 18).background(Capsule().fill(Color.blue.gradient)).shadow(color: .blue.opacity(0.4), radius: 10, y: 5) }.padding(.bottom, isLandscape ? 5 : 10)
            }.padding(isLandscape ? 15 : 30).background(Color.white.cornerRadius(isLandscape ? 30 : 40)).padding(.horizontal, isLandscape ? 60 : 40).frame(maxWidth: 650)
        }
    }
}

struct MagicBoxSurpriseView: View {
    @Binding var isPresented: Bool; @State private var revealed = false
    var body: some View { ZStack { Color.black.opacity(0.8).ignoresSafeArea().onTapGesture { isPresented = false }; VStack(spacing: 30) { if !revealed { Text(LocalizedStringKey("TAP THE BOX!")).font(.title.bold()).foregroundColor(.white); Image(systemName: "archivebox.fill").font(.system(size: 150)).foregroundColor(.orange).onTapGesture { withAnimation { revealed = true } } } else { Text(LocalizedStringKey("YOU GOT A STICKER!")).font(.title.bold()).foregroundColor(.white); Image(systemName: "pawprint.fill").font(.system(size: 120)).foregroundColor(.yellow); Button(LocalizedStringKey("Cool!")) { isPresented = false }.padding().background(Capsule().fill(Color.green)).foregroundColor(.white) } } } }
}
