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
                    // 1. Background
                    LinearGradient(colors: [Color(red: 0.95, green: 0.98, blue: 1.0), .white], startPoint: .top, endPoint: .bottom)
                        .ignoresSafeArea()
                    DoodleBackgroundView().opacity(0.4).ignoresSafeArea()
                    
                    // 2. CENTER CONTENT
                    VStack(spacing: isLandscape ? 15 : 40) {
                        if profileManager.currentProfile.ageGroup != nil {
                            // Star Counter
                            HStack(spacing: 8) {
                                Image(systemName: "star.fill")
                                    .foregroundStyle(LinearGradient(colors: [.yellow, .orange], startPoint: .top, endPoint: .bottom))
                                    .font(.title2)
                                    .shadow(color: .orange.opacity(0.3), radius: 5)
                                    .symbolEffect(.bounce, value: profileManager.currentProfile.stars)
                                
                                Text("\(profileManager.currentProfile.stars)")
                                    .font(.system(size: 22, weight: .black, design: .rounded))
                                    .foregroundColor(.orange)
                            }
                            .padding(.horizontal, 15)
                            .padding(.vertical, 6)
                            .background(Capsule().fill(Color.white).shadow(color: .black.opacity(0.05), radius: 5))
                            .transition(.move(edge: .top).combined(with: .opacity))
                        }
                        
                        if profileManager.currentProfile.ageGroup == nil {
                            Text("PureColor")
                                .font(.system(size: isLandscape ? 44 : 60, weight: .black, design: .rounded))
                                .foregroundStyle(LinearGradient(colors: [.blue, .purple, .pink], startPoint: .leading, endPoint: .trailing))
                                .handDrawn()
                        }
                        
                        if let childAge = profileManager.currentProfile.ageGroup {
                            VStack(spacing: 20) {
                                Text("Hello, \(profileManager.currentProfile.name)!").font(.system(size: 24, weight: .bold, design: .rounded)).foregroundColor(.black.opacity(0.6))
                                Button {
                                    AudioManager.shared.playPop()
                                    path.append(.categoryWheel(childAge))
                                } label: {
                                    VStack(spacing: 15) {
                                        AgeGroupCard(age: childAge, isIPad: isIPad, isLandscape: isLandscape).scaleEffect(1.2)
                                        Text("TAP TO PLAY").font(.system(size: 20, weight: .black, design: .rounded)).foregroundColor(.white).padding(.horizontal, 40).padding(.vertical, 12).background(Capsule().fill(childAge.color.gradient)).shadow(color: childAge.color.opacity(0.3), radius: 10, y: 5)
                                    }
                                }
                                Button("Switch Profile") { withAnimation { profileManager.currentProfileIndex = 0 } }.font(.caption.bold()).foregroundColor(.gray)
                            }
                        } else {
                            HStack(spacing: isLandscape ? 60 : 30) {
                                ForEach(AgeGroup.allCases) { age in
                                    Button {
                                        AudioManager.shared.playPop()
                                        path.append(.categoryWheel(age))
                                    } label: {
                                        AgeGroupCard(age: age, isIPad: isIPad, isLandscape: isLandscape)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            Button { pendingAction = { showAddProfile = true }; showParentalGate = true } label: {
                                Text("Create Artist Profile").font(.headline.bold()).foregroundColor(.white).padding(.horizontal, 30).padding(.vertical, 15).background(Capsule().fill(Color.blue.gradient)).shadow(color: .blue.opacity(0.3), radius: 10, y: 5)
                            }.padding(.top, 10)
                        }
                    }
                    
                    // 3. LEFT SIDE CONTROLS
                    VStack(spacing: 20) {
                        VStack(spacing: 6) {
                            HeaderCircleButton(icon: profileManager.currentProfile.avatar, color: .blue) {
                                withAnimation(.spring()) { showProfilePicker = true }
                            }
                            if !profileManager.currentProfile.name.isEmpty {
                                Text(profileManager.currentProfile.name).font(.system(size: 11, weight: .black, design: .rounded)).foregroundColor(.blue)
                            }
                        }
                        HeaderCircleButton(icon: "photo.on.rectangle.angled", color: .green) { 
                            AudioManager.shared.playPop()
                            showGallery = true 
                        }
                        Button { withAnimation(.spring()) { showMagicBoxSurprise = true } } label: {
                            ZStack { RoundedRectangle(cornerRadius: 15).fill(Color.orange.gradient); Image(systemName: "archivebox.fill").font(.title2).foregroundColor(.white) }
                            .frame(width: 50, height: 50).shadow(color: .orange.opacity(0.3), radius: 5, y: 3)
                        }
                        HeaderSquareButton(icon: "star.bubble.fill", color: .yellow) {
                            pendingAction = {
                                if let url = URL(string: "https://apps.apple.com/app/idYOUR_APP_ID?action=write-review") {
                                    UIApplication.shared.open(url)
                                }
                            }
                            showParentalGate = true
                        }
                        Spacer()
                    }
                    .padding(.leading, 20).padding(.top, 20).frame(maxWidth: .infinity, alignment: .leading)
                    
                    // 4. RIGHT SIDE CONTROLS
                    VStack(spacing: 15) {
                        HeaderCircleButton(icon: "gearshape.fill", color: .gray) {
                            pendingAction = { showParentSettings = true }
                            showParentalGate = true
                        }
                        HeaderSquareButton(icon: "timer", color: timerSecondsRemaining != nil ? .red : .orange) {
                            pendingAction = { showTimerPicker = true }
                            showParentalGate = true
                        }
                        HeaderSquareButton(icon: musicEnabled ? "music.note" : "music.note.list", color: .purple) { 
                            musicEnabled.toggle() 
                            AudioManager.shared.playPop()
                        }
                        HeaderSquareButton(icon: soundEnabled ? "speaker.wave.3.fill" : "speaker.slash.fill", color: .pink) { 
                            soundEnabled.toggle() 
                            AudioManager.shared.playPop()
                        }
                        if let remaining = timerSecondsRemaining {
                            VStack(spacing: 2) {
                                Image(systemName: remaining < 300 ? "moon.stars.fill" : "sun.max.fill").font(.caption).foregroundColor(remaining < 300 ? .indigo : .orange)
                                Text(timeString(from: remaining)).font(.system(size: 8, weight: .bold, design: .monospaced))
                            }.padding(6).background(Capsule().fill(Color.white).shadow(radius: 3))
                        }
                        Spacer()
                    }
                    .padding(.trailing, 20).padding(.top, 20).frame(maxWidth: .infinity, alignment: .trailing)
                    
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

// MARK: - PREMIUM COMPONENTS RESTORED
struct DoodleBackgroundView: View {
    var body: some View {
        ZStack {
            ForEach(0..<15) { i in
                Image(systemName: ["star.fill", "heart.fill", "moon.fill", "cloud.fill", "sparkles"].randomElement()!)
                    .font(.system(size: CGFloat.random(in: 20...50)))
                    .foregroundColor(Color(hue: Double.random(in: 0...1), saturation: 0.2, brightness: 0.9))
                    .position(x: CGFloat.random(in: 0...1200), y: CGFloat.random(in: 0...900))
                    .rotationEffect(.degrees(Double.random(in: 0...360)))
            }
        }
    }
}

struct AgeGroupCard: View {
    let age: AgeGroup; let isIPad: Bool; let isLandscape: Bool; @State private var isAnimating = false
    var body: some View {
        let cardWidth: CGFloat = isIPad ? 220 : (isLandscape ? 130 : 160)
        VStack(spacing: 12) {
            ZStack { Circle().fill(Color.white).frame(width: cardWidth * 0.75, height: cardWidth * 0.75).shadow(color: age.color.opacity(0.2), radius: 10, y: 5); Image(systemName: age.icon).font(.system(size: cardWidth * 0.4)).foregroundColor(age.color).handDrawn() }.scaleEffect(isAnimating ? 1.05 : 1.0)
            VStack(spacing: 2) { Text(age.rawValue).font(.system(size: isLandscape ? 15 : 18, weight: .black, design: .rounded)).foregroundColor(.black); Text(age == .toddlers ? "Easy Play" : (age == .kids ? "Creative" : "Artist")).font(.system(size: isLandscape ? 11 : 14, weight: .bold, design: .rounded)).foregroundColor(.black.opacity(0.4)) }.padding(.horizontal, 15).padding(.vertical, 8).background(Capsule().fill(Color.white).shadow(color: .black.opacity(0.05), radius: 5, y: 2))
        }.frame(width: cardWidth).onAppear { withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) { isAnimating = true } }
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
            Text(category.name).font(.system(size: size.height * 0.08, weight: Font.Weight.black, design: .rounded)).foregroundColor(.white).modifier(StrokeModifier(strokeColor: category.color.opacity(0.8), lineWidth: 8)).shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 4).rotationEffect(.degrees(-5)).handDrawn().offset(y: -size.height * 0.25)
            ForEach(0..<8) { i in Image(systemName: i % 2 == 0 ? "star.fill" : "circle.fill").font(.system(size: size.height * 0.03)).foregroundColor(.white.opacity(0.6)).offset(x: CGFloat.random(in: -size.height * 0.25...size.height * 0.25), y: CGFloat.random(in: -size.height * 0.25...size.height * 0.25)) }
            ZStack { Image(systemName: category.icon).font(.system(size: size.height * 0.12)).foregroundColor(.white).background(Circle().fill(Color.white).blur(radius: 10)).offset(x: -size.height * 0.12, y: -size.height * 0.08); Image(systemName: category.icon).font(.system(size: size.height * 0.1)).foregroundColor(.white).background(Circle().fill(Color.white).blur(radius: 10)).offset(x: size.height * 0.15, y: -size.height * 0.05); Image(systemName: category.icon).font(.system(size: size.height * 0.11)).foregroundColor(.white).background(Circle().fill(Color.white).blur(radius: 10)).offset(x: -size.height * 0.05, y: size.height * 0.12); ZStack { Circle().fill(Color.white).frame(width: size.height * 0.22, height: size.height * 0.22); Image(systemName: category.icon).font(.system(size: size.height * 0.16)).foregroundColor(category.color) }.handDrawn().shadow(radius: 10) }
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
    var body: some View {
        ZStack {
            Color.black.opacity(0.4).ignoresSafeArea().onTapGesture { isPresented = false }
            VStack(spacing: 20) {
                Text("App Settings").font(.title2.weight(.black)).foregroundColor(.black)
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 15) {
                        Group { Toggle("Sound Effects", isOn: $soundEnabled); Toggle("Background Music", isOn: $musicEnabled) }.padding(10).background(Color.gray.opacity(0.05)).cornerRadius(12)
                        Divider()
                        VStack(spacing: 12) { SettingsRow(icon: "questionmark.circle.fill", title: "Support", color: .blue); SettingsRow(icon: "lock.shield.fill", title: "Privacy Policy", color: .green); SettingsRow(icon: "doc.text.fill", title: "Terms of Use", color: .orange) }
                    }
                }.frame(maxHeight: 250)
                Button("Done") { withAnimation { isPresented = false } }.font(.headline).foregroundColor(.white).padding(.horizontal, 50).padding(.vertical, 12).background(Capsule().fill(Color.blue))
            }.padding(25).background(RoundedRectangle(cornerRadius: 30).fill(Color.white)).padding(30).frame(maxWidth: 400)
        }
    }
}

struct SettingsRow: View {
    let icon: String; let title: String; let color: Color
    var body: some View { HStack { Image(systemName: icon).foregroundColor(color).font(.title3); Text(title).font(.body.weight(.medium)); Spacer(); Image(systemName: "chevron.right").font(.caption).foregroundColor(.gray) }.padding(12).background(Color.gray.opacity(0.05)).cornerRadius(12) }
}

struct DailyRewardPopup: View {
    @Binding var isPresented: Bool; @StateObject private var profileManager = ProfileManager.shared
    var body: some View { ZStack { Color.black.opacity(0.8).ignoresSafeArea(); VStack(spacing: 25) { Text("Daily Prize!").font(.system(size: 32, weight: .black, design: .rounded)).foregroundColor(.white); ZStack { Circle().fill(Color.yellow.gradient).frame(width: 150, height: 150); Image(systemName: "star.fill").font(.system(size: 80)).foregroundColor(.white).shadow(radius: 10) }; Text("You earned 5 Stars!").font(.title2.bold()).foregroundColor(.white); Button { AudioManager.shared.playSuccess(); profileManager.currentProfile.stars += 5; profileManager.currentProfile.lastDailyRewardClaimed = Date(); profileManager.save(); withAnimation { isPresented = false } } label: { Text("Collect").font(.headline).foregroundColor(.white).padding(.horizontal, 40).padding(.vertical, 15).background(Capsule().fill(Color.blue)) } }.padding(40).background(RoundedRectangle(cornerRadius: 30).fill(Color.white.opacity(0.1)).background(.ultraThinMaterial)).cornerRadius(30).padding(40) } }
}

struct TimerSelectionPopup: View {
    @Binding var isPresented: Bool; @Binding var timerSecondsRemaining: Int?; @Binding var timerActive: Bool
    var body: some View { ZStack { Rectangle().fill(.ultraThinMaterial).overlay(Color.black.opacity(0.2)).ignoresSafeArea().onTapGesture { isPresented = false }; VStack(spacing: 25) { Text("Set Screen Time").font(.system(size: 24, weight: .black, design: .rounded)); HStack(spacing: 15) { ForEach([20, 60, 120], id: \.self) { mins in Button { timerSecondsRemaining = mins * 60; timerActive = true; isPresented = false } label: { VStack { Text("\(mins >= 60 ? mins/60 : mins)").font(.system(size: 28, weight: .black)); Text(mins >= 60 ? "HOUR" : "MIN").font(.caption.bold()) }.frame(width: 80, height: 90).background(RoundedRectangle(cornerRadius: 20).fill(timerSecondsRemaining == mins * 60 ? Color.blue : Color.white)).foregroundColor(timerSecondsRemaining == mins * 60 ? .white : .blue) } } }; Button("Turn Off") { timerSecondsRemaining = nil; timerActive = false; isPresented = false }.foregroundColor(.red) }.padding(30).background(RoundedRectangle(cornerRadius: 35).fill(Color.white)).frame(maxWidth: 400).padding(20) } }
}

struct TimesUpView: View {
    @Binding var isPresented: Bool; @Binding var timerSecondsRemaining: Int?; @Binding var timerActive: Bool; @State private var showParentalGate = false
    var body: some View { ZStack { Color.white.ignoresSafeArea(); DoodleBackgroundView().opacity(0.3); VStack(spacing: 30) { ZStack { Circle().fill(Color.orange.opacity(0.1)).frame(width: 200, height: 200); Image(systemName: "moon.stars.fill").font(.system(size: 100)).foregroundColor(.orange) }; Text("Time to Rest!").font(.system(size: 40, weight: .black, design: .rounded)); Button { showParentalGate = true } label: { Text("Parents Only").padding(.horizontal, 40).padding(.vertical, 15).background(Capsule().fill(Color.blue)).foregroundColor(.white) } } }.fullScreenCover(isPresented: $showParentalGate) { ParentalGateView { timerSecondsRemaining = nil; timerActive = false; isPresented = false }.presentationBackground(.clear) } }
}

struct ProfileSelectionPopup: View {
    @Binding var isPresented: Bool; @StateObject private var profileManager = ProfileManager.shared
    var body: some View { ZStack { Rectangle().fill(.ultraThinMaterial).overlay(Color.black.opacity(0.2)).ignoresSafeArea().onTapGesture { isPresented = false }; VStack(spacing: 20) { Text("Who is coloring?").font(.title2.bold()); ScrollView(.horizontal, showsIndicators: false) { HStack(spacing: 20) { ForEach(0..<profileManager.profiles.count, id: \.self) { i in Button { profileManager.currentProfileIndex = i; withAnimation { isPresented = false } } label: { VStack { ZStack { Circle().fill(profileManager.currentProfileIndex == i ? Color.blue : Color.white).frame(width: 80, height: 80); Image(systemName: profileManager.profiles[i].avatar).font(.title).foregroundColor(profileManager.currentProfileIndex == i ? .white : .blue) }; Text(profileManager.profiles[i].name).font(.caption.bold()) } } } } }.padding(.horizontal, 20); Button("Close") { withAnimation { isPresented = false } }.foregroundColor(.gray) }.padding(.vertical, 30).background(RoundedRectangle(cornerRadius: 30).fill(Color.white)).padding(30).frame(maxWidth: 500) } }
}

struct AddProfilePopup: View {
    @Binding var isPresented: Bool; let isLandscape: Bool; @StateObject private var profileManager = ProfileManager.shared; @State private var name = ""; @State private var selectedAge: AgeGroup = .toddlers
    var body: some View { ZStack { Color.black.opacity(0.7).ignoresSafeArea(); VStack(spacing: 20) { Text("New Artist!").font(.title.bold()); TextField("Name", text: $name).textFieldStyle(.roundedBorder).padding(.horizontal); HStack { ForEach(AgeGroup.allCases) { age in Button { selectedAge = age } label: { Text(age.rawValue).font(.caption.bold()).padding(8).background(selectedAge == age ? age.color : Color.gray.opacity(0.1)).foregroundColor(selectedAge == age ? .white : .gray).cornerRadius(8) } } }; Button("Create") { let newP = UserProfile(id: UUID(), name: name, avatar: "face.smiling.fill", ageGroup: selectedAge, stars: 0, lastDailyRewardClaimed: nil, collectedStickers: []); profileManager.profiles.append(newP); profileManager.currentProfileIndex = profileManager.profiles.count - 1; profileManager.save(); isPresented = false }.padding().background(Capsule().fill(Color.blue)).foregroundColor(.white).disabled(name.isEmpty) }.padding(30).background(Color.white.cornerRadius(25)).padding(30).frame(maxWidth: 450) } }
}

struct MagicBoxSurpriseView: View {
    @Binding var isPresented: Bool; @State private var revealed = false
    var body: some View { ZStack { Color.black.opacity(0.8).ignoresSafeArea().onTapGesture { isPresented = false }; VStack(spacing: 30) { if !revealed { Text("TAP THE BOX!").font(.title.bold()).foregroundColor(.white); Image(systemName: "archivebox.fill").font(.system(size: 150)).foregroundColor(.orange).onTapGesture { withAnimation { revealed = true } } } else { Text("YOU GOT A STICKER!").font(.title.bold()).foregroundColor(.white); Image(systemName: "pawprint.fill").font(.system(size: 120)).foregroundColor(.yellow); Button("Cool!") { isPresented = false }.padding().background(Capsule().fill(Color.green)).foregroundColor(.white) } } } }
}
