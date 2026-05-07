import SwiftUI
import PencilKit

struct ColoringCanvasView: View {
    let category: Category
    let drawingItem: DrawingItem
    var existingArtwork: SavedArtwork? = nil // Added: To resume drawing
    @Environment(\.dismiss) var dismiss
    
    // PencilKit State
    @State private var canvasView = PKCanvasView()
    @State private var existingId: UUID? = nil // Internal state to track updates
    
    // Custom Tool State
    @State private var selectedColor: Color = .black
    @State private var selectedTool: PKInkingTool.InkType = .pen
    @State private var brushWidth: CGFloat = 10
    @State private var isEraser = false
    
    // NEW: Advanced Tools State
    @State private var activeCategory: String? = nil
    @State private var currentBrushName: String = "Pen"
    
    // UI State
    @State private var showSizePanel = false
    @State private var isLocked = false
    
    // Age-based Config
    private var ageConfig: AgeGroupConfig {
        AgeManager.shared.config(for: ProfileManager.shared.currentProfile.ageGroup ?? .toddlers)
    }
    
    var filteredCategories: [String] {
        ["Basic", "Sketch", "Paint", "Ink", "Maquillage", "Shine", "Magic", "Patterns", "Stickers", "Mélangeur"]
            .filter { ageConfig.toolCategories.contains($0) }
    }
    
    var filteredColors: [Color] {
        ageConfig.availableColors.isEmpty ? gridColors : ageConfig.availableColors
    }
    
    // Brush Definitions with specific properties (Khasiyat)
    let toolGroups: [String: [(name: String, icon: String, type: PKInkingTool.InkType, width: CGFloat, opacity: CGFloat)]] = [
        "Basic": [
            ("Pen", "pencil.tip", .pen, 5, 1.0),
            ("Pencil", "pencil", .pencil, 2, 0.8),
            ("Marker", "highlighter", .marker, 15, 0.6)
        ],
        "Sketch": [
            ("Sketch", "pencil.and.outline", .pencil, 3, 0.7),
            ("Makeup Pen", "mouth.fill", .pen, 4, 0.9)
        ],
        "Paint": [
            ("Watercolor", "paintbrush.pointed", .pen, 25, 0.4),
            ("Splatter", "cloud.heavyrain", .marker, 40, 0.5),
            ("Oil", "paintbrush", .pen, 20, 1.0),
            ("Flat Brush", "pencil.line", .marker, 30, 0.8),
            ("Smooth Hair", "hand.raised.fill", .marker, 12, 0.7),
            ("Fuzzy Fur", "pawprint.fill", .marker, 18, 0.6),
            ("Cozy Coat", "tshirt.fill", .marker, 22, 0.5)
        ],
        "Ink": [
            ("Ink", "fountainpen.tip", .pen, 6, 1.0),
            ("Spray", "wind", .marker, 35, 0.3)
        ],
        "Maquillage": [
            ("Foundation", "face.smiling", .pen, 30, 0.3),
            ("Blush", "sparkles", .marker, 25, 0.4)
        ],
        "Shine": [
            ("Sparkle", "wand.and.stars", .pen, 8, 1.0),
            ("Glitter", "particle.fill", .marker, 15, 0.9),
            ("Plasma", "bolt.horizontal", .pen, 10, 0.8),
            ("Laser", "flashlight.on.fill", .pen, 4, 1.0),
            ("Nebula", "cloud.sun.bolt.fill", .marker, 50, 0.2)
        ],
        "Magic": [
            ("Rainbow", "rainbow", .pen, 10, 1.0),
            ("Fill", "paintbucket.fill", .marker, 80, 1.0)
        ],
        "Patterns": [
            ("Hearts", "heart.fill", .marker, 20, 0.8),
            ("Stars", "star.fill", .marker, 20, 0.8),
            ("Dots", "circle.grid.2x2.fill", .marker, 20, 0.8)
        ],
        "Stickers": [
            ("Smiley", "face.smiling.fill", .pen, 15, 1.0),
            ("Animal", "pawprint.fill", .pen, 15, 1.0),
            ("Gift", "gift.fill", .pen, 15, 1.0)
        ],
        "Mélangeur": [
            ("Blender", "circle.dotted.circle", .pen, 20, 0.2),
            ("Mixer", "wind.snow", .marker, 30, 0.1)
        ]
    ]
    
    @State private var currentWidth: CGFloat = 10
    @State private var currentOpacity: CGFloat = 1.0
    @State private var showColorFlyout = false
    @State private var showSizeFlyout = false
    @State private var flyoutOffset: CGSize = .zero
    
    let gridColors: [Color] = [
        .red, .orange, .yellow, .green, .blue, .purple, .pink, .brown, .black, .gray,
        .white, .cyan, .mint, .indigo, .teal, Color(red: 1, green: 0.5, blue: 0.5),
        Color(red: 0.5, green: 1, blue: 0.5), Color(red: 0.5, green: 0.5, blue: 1),
        .yellow.opacity(0.8), .purple.opacity(0.8)
    ]
    
    var body: some View {
        ZStack {
            // 1. Premium Background
            Color(red: 0.6, green: 0.9, blue: 1.0).ignoresSafeArea()
            DoodleBackgroundView().opacity(0.1).ignoresSafeArea()
            
            HStack(spacing: 0) {
                leftSidebar
                mainCanvasArea
                rightSidebar
            }
            
            // --- OVERLAYS ---
            toolPickerOverlay
            colorPickerOverlay
            sizePickerOverlay
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            // Initial setup based on age
            currentWidth = ageConfig.defaultWidth
            if let firstColor = filteredColors.first {
                selectedColor = firstColor
            }
            
            // Load existing drawing if resuming
            if let artwork = existingArtwork {
                existingId = artwork.id
                if let drawing = GalleryManager.shared.getDrawing(for: artwork) {
                    canvasView.drawing = drawing
                }
            }
            
            updateTool()
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: .landscape))
            }
        }
    }
    
    // MARK: - Subviews
    
    @ViewBuilder
    private var leftSidebar: some View {
        VStack(spacing: 12) {
            // EXIT
            HeaderCircleButton(icon: "xmark", color: isLocked ? .gray : .red) {
                if !isLocked { AudioManager.shared.playPop(); dismiss() }
            }
            .disabled(isLocked)
            .scaleEffect(0.8)
            
            Divider().frame(width: 25).background(Color.white.opacity(0.3))
            
            // UNDO/REDO
            VStack(spacing: 8) {
                HeaderSquareButton(icon: "arrow.uturn.backward", color: .orange) {
                    canvasView.undoManager?.undo()
                }
                HeaderSquareButton(icon: "arrow.uturn.forward", color: .orange) {
                    canvasView.undoManager?.redo()
                }
            }
            .scaleEffect(0.75)
            
            // TRASH
            HeaderSquareButton(icon: "trash", color: .gray) {
                canvasView.drawing = PKDrawing()
                AudioManager.shared.playPop()
            }
            .scaleEffect(0.75)
            
            Spacer()
            
            // LOCK
            Button {
                withAnimation(.spring()) { isLocked.toggle(); AudioManager.shared.playPop() }
            } label: {
                ZStack {
                    Circle().fill(isLocked ? Color.orange.gradient : Color.white.gradient).frame(width: 40, height: 40).shadow(radius: 3)
                    Image(systemName: isLocked ? "lock.fill" : "lock.open.fill").font(.system(size: 12, weight: .bold)).foregroundColor(isLocked ? .white : .orange)
                }.overlay(Circle().stroke(Color.white, lineWidth: 2))
            }
            
            Divider().frame(width: 25).background(Color.white.opacity(0.3))
            
            // DONE
            HeaderCircleButton(icon: "checkmark", color: isLocked ? .gray : .green) {
                if !isLocked { saveAndExit(); AudioManager.shared.playSuccess() }
            }
            .disabled(isLocked)
            .scaleEffect(0.9)
        }
        .padding(.vertical, 20)
        .padding(.leading, 10)
        .frame(width: 70)
    }
    
    @ViewBuilder
    private var mainCanvasArea: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 30)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.1), radius: 10)
            
            PencilKitView(canvasView: $canvasView)
                .cornerRadius(30)
                .simultaneousGesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { _ in
                            withAnimation(.spring()) {
                                activeCategory = nil
                                showColorFlyout = false
                            }
                        }
                )
            
            // --- Reset Zoom Button ---
            VStack {
                HStack {
                    Spacer()
                    Button {
                        withAnimation(.spring()) {
                            canvasView.setZoomScale(1.0, animated: true)
                        }
                        AudioManager.shared.playPop()
                    } label: {
                        Image(systemName: "minus.magnifyingglass")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.blue)
                            .padding(10)
                            .background(Circle().fill(.white).shadow(radius: 3))
                    }
                    .padding(15)
                }
                Spacer()
            }
            
            Image(systemName: drawingItem.imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 300, height: 300)
                .foregroundColor(.black.opacity(0.8))
                .allowsHitTesting(false)
                .opacity(0.9)
        }
        .padding(.top, 40)
        .padding(.bottom, 20)
        .padding(.horizontal, 10)
    }
    
    @ViewBuilder
    private var rightSidebar: some View {
        VStack(spacing: 0) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 12) {
                    ForEach(filteredCategories, id: \.self) { category in
                        CategoryIcon(name: category, isSelected: activeCategory == category) {
                            withAnimation(.spring()) {
                                activeCategory = (activeCategory == category) ? nil : category
                                showColorFlyout = false
                                showSizeFlyout = false
                            }
                        }
                    }
                    
                    CategoryIcon(name: "Eraser", icon: "eraser.fill", isSelected: isEraser) {
                        isEraser = true
                        activeCategory = nil
                        showColorFlyout = false
                        showSizeFlyout = false
                        canvasView.tool = PKEraserTool(.bitmap, width: currentWidth)
                        AudioManager.shared.playPop()
                    }
                }
                .padding(.vertical, 15)
            }
            
            Divider().padding(.horizontal, 10).background(Color.gray.opacity(0.1))
            
            Button {
                withAnimation(.spring()) {
                    showColorFlyout.toggle()
                    activeCategory = nil
                    showSizeFlyout = false
                }
                AudioManager.shared.playPop()
            } label: {
                VStack(spacing: 4) {
                    ZStack {
                        Circle().fill(AngularGradient(gradient: Gradient(colors: [.red, .yellow, .green, .blue, .purple, .red]), center: .center))
                        Image(systemName: "eyedropper").foregroundColor(.white).font(.system(size: 14, weight: .bold))
                    }
                    .frame(width: 38, height: 38)
                    .overlay(Circle().stroke(Color.blue, lineWidth: showColorFlyout ? 3 : 0))
                    Text("Colors").font(.system(size: 8, weight: .bold))
                }
            }
            .padding(.top, 10)
            .padding(.bottom, 20)
        }
        .frame(width: 80)
        .background(
            RoundedRectangle(cornerRadius: 35)
                .fill(Color.white.opacity(0.9))
                .shadow(color: .black.opacity(0.05), radius: 10)
        )
        .padding(.vertical, 40)
        .padding(.trailing, 15)
    }
    
    @ViewBuilder
    private var toolPickerOverlay: some View {
        if let category = activeCategory {
            VStack(spacing: 8) {
                HStack {
                    Image(systemName: "line.3.horizontal")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white.opacity(0.6))
                    Spacer()
                    Button { withAnimation { activeCategory = nil } } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.white.opacity(0.6))
                            .font(.system(size: 22))
                    }
                }
                .padding(.horizontal, 12)
                .padding(.top, 12)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 12) {
                        if let groupTools = toolGroups[category] {
                            ForEach(groupTools, id: \.name) { tool in
                                Button {
                                    currentBrushName = tool.name
                                    selectedTool = tool.type
                                    currentWidth = tool.width
                                    currentOpacity = tool.opacity
                                    isEraser = false
                                    updateTool()
                                    AudioManager.shared.playPop()
                                } label: {
                                    VStack(spacing: 4) {
                                        Image(systemName: tool.icon)
                                            .font(.system(size: 24))
                                        Text(tool.name).font(.system(size: 9, weight: .bold))
                                    }
                                    .frame(width: 80, height: 75)
                                    .background(currentBrushName == tool.name ? Color.white.opacity(0.2) : Color.clear)
                                    .cornerRadius(18)
                                    .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.white.opacity(0.1), lineWidth: 1))
                                    .foregroundColor(.white)
                                }
                            }
                        }
                    }
                    .padding(.vertical, 5)
                }
                
                Divider().background(Color.white.opacity(0.2))
                
                HStack(spacing: 15) {
                    ForEach([5, 35, 90], id: \.self) { size in
                        Button {
                            currentWidth = CGFloat(size)
                            updateTool()
                            AudioManager.shared.playPop()
                        } label: {
                            Circle()
                                .fill(currentWidth == CGFloat(size) ? Color.white : Color.white.opacity(0.3))
                                .frame(width: CGFloat(size / 6 + 12), height: CGFloat(size / 6 + 12))
                                .overlay(Circle().stroke(Color.white.opacity(0.5), lineWidth: 1))
                        }
                    }
                }
                .padding(.vertical, 15)
            }
            .frame(width: 110, height: 320)
            .background(.ultraThinMaterial)
            .background(Color.black.opacity(0.4))
            .clipShape(RoundedRectangle(cornerRadius: 30))
            .shadow(color: .black.opacity(0.3), radius: 15)
            .offset(flyoutOffset)
            .gesture(
                DragGesture()
                    .onChanged { gesture in flyoutOffset = gesture.translation }
            )
            .padding(.trailing, 100)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .trailing)
            .transition(.asymmetric(
                insertion: .move(edge: .trailing).combined(with: .opacity),
                removal: .opacity.combined(with: .scale(scale: 0.9))
            ))
        }
    }
    
    @ViewBuilder
    private var colorPickerOverlay: some View {
        if showColorFlyout {
            VStack(spacing: 12) {
                Text("Colors").font(.caption.bold()).foregroundColor(.gray)
                ScrollView(showsIndicators: false) {
                    LazyVGrid(columns: [GridItem(.fixed(30)), GridItem(.fixed(30))], spacing: 12) {
                        ForEach(filteredColors, id: \.self) { color in
                            Button {
                                selectedColor = color
                                updateTool()
                                withAnimation { showColorFlyout = false }
                                AudioManager.shared.playPop()
                            } label: {
                                Circle()
                                    .fill(color)
                                    .frame(width: 32, height: 32)
                                    .overlay(Circle().stroke(Color.white, lineWidth: selectedColor == color ? 3 : 1))
                                    .shadow(color: .black.opacity(0.15), radius: 3)
                            }
                        }
                    }
                    .padding(.vertical, 10)
                }
            }
            .frame(width: 90, height: 260)
            .background(RoundedRectangle(cornerRadius: 30).fill(.ultraThinMaterial))
            .shadow(color: .black.opacity(0.15), radius: 10)
            .padding(.trailing, 105)
            .padding(.bottom, 60)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
            .transition(.asymmetric(
                insertion: .move(edge: .trailing).combined(with: .opacity),
                removal: .opacity.combined(with: .scale(scale: 0.9))
            ))
        }
    }
    
    @ViewBuilder
    private var sizePickerOverlay: some View {
        if showSizeFlyout {
            VStack(spacing: 15) {
                Text("Size").font(.caption.bold()).foregroundColor(.gray)
                Circle()
                    .fill(selectedColor)
                    .frame(width: currentWidth, height: currentWidth)
                    .frame(width: 50, height: 50)
                    .background(Circle().stroke(Color.gray.opacity(0.2), lineWidth: 1))
                Slider(value: $currentWidth, in: 2...80)
                    .accentColor(.blue)
                    .frame(width: 150)
                    .rotationEffect(.degrees(-90))
                    .frame(height: 160)
                    .onChange(of: currentWidth) { _ in updateTool() }
                Button("Done") { withAnimation { showSizeFlyout = false } }
                    .font(.caption2.bold())
                    .foregroundColor(.blue)
            }
            .padding(.vertical, 15)
            .frame(width: 80)
            .background(RoundedRectangle(cornerRadius: 30).fill(.ultraThinMaterial))
            .shadow(color: .black.opacity(0.15), radius: 10)
            .padding(.trailing, 105)
            .padding(.bottom, 120)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
            .transition(.asymmetric(
                insertion: .move(edge: .trailing).combined(with: .opacity),
                removal: .opacity.combined(with: .scale(scale: 0.9))
            ))
        }
    }
    
    func toggleSizePanel() {
        withAnimation { showSizePanel.toggle() }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            withAnimation { showSizePanel = false }
        }
    }
    
    func updateTool() {
        let colorWithOpacity = UIColor(selectedColor).withAlphaComponent(currentOpacity)
        canvasView.tool = PKInkingTool(selectedTool, color: colorWithOpacity, width: currentWidth)
    }
    
    @MainActor
    func saveAndExit() {
        // 1. Get the drawing image
        let drawingImage = canvasView.drawing.image(from: canvasView.bounds, scale: 1.0)
        
        // 2. Composite with template image
        let templateImage = UIImage(systemName: drawingItem.imageName) ?? UIImage()
        let size = canvasView.bounds.size
        
        let renderer = UIGraphicsImageRenderer(size: size)
        let compositeImage = renderer.image { context in
            // Draw background (white)
            UIColor.white.setFill()
            context.fill(CGRect(origin: .zero, size: size))
            
            // Draw template image centered
            let templateSize = CGSize(width: 300, height: 300)
            let templateRect = CGRect(
                x: (size.width - templateSize.width) / 2,
                y: (size.height - templateSize.height) / 2,
                width: templateSize.width,
                height: templateSize.height
            )
            templateImage.withTintColor(.black.withAlphaComponent(0.8)).draw(in: templateRect)
            
            // Draw strokes on top
            drawingImage.draw(in: CGRect(origin: .zero, size: size))
        }
        
        // 3. Save everything
        GalleryManager.shared.saveArtwork(
            image: compositeImage,
            drawing: canvasView.drawing,
            category: category.name,
            drawingItemName: drawingItem.imageName,
            profileId: ProfileManager.shared.currentProfile.id,
            existingId: existingId
        )
        
        ProfileManager.shared.addStar()
        dismiss()
    }
}

struct CategoryIcon: View {
    let name: String
    var icon: String? = nil
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon ?? categoryIcon(for: name))
                    .font(.system(size: 22, weight: .semibold))
                Text(name).font(.system(size: 9, weight: .bold))
            }
            .frame(width: 60, height: 60)
            .background(isSelected ? Color.blue.opacity(0.1) : Color.clear)
            .cornerRadius(15)
            .foregroundColor(isSelected ? .blue : .gray)
            .scaleEffect(isSelected ? 1.1 : 1.0)
        }
    }
    
    func categoryIcon(for name: String) -> String {
        switch name {
        case "Basic": return "pencil.tip"
        case "Sketch": return "pencil.and.outline"
        case "Paint": return "paintpalette.fill"
        case "Ink": return "fountainpen.tip"
        case "Maquillage": return "face.smiling"
        case "Shine": return "sparkles"
        case "Magic": return "magicmouse"
        case "Patterns": return "circle.grid.2x2.fill"
        case "Stickers": return "face.smiling.fill"
        case "Mélangeur": return "circle.dotted.circle"
        default: return "square.grid.2x2"
        }
    }
}

// Helper to detect notch
extension UIDevice {
    var hasNotch: Bool {
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        let window = windowScene?.windows.first
        return window?.safeAreaInsets.left ?? 0 > 0 || window?.safeAreaInsets.top ?? 0 > 20
    }
}
