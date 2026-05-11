import SwiftUI
import PencilKit
import PhotosUI
import Combine

typealias ToolConfig = (name: String, icon: String, type: PKInkingTool.InkType, width: CGFloat, opacity: CGFloat)

struct ColoringCanvasView: View {
    let category: Category
    let drawingItem: DrawingItem
    var existingArtwork: SavedArtwork? = nil 
    @Environment(\.dismiss) var dismiss
    
    @State private var canvasView = PKCanvasView()
    @State private var existingId: UUID? = nil 
    @State private var selectedColor: Color = .black
    @State private var selectedTool: PKInkingTool.InkType = .pen
    @State private var brushWidth: CGFloat = 10
    @State private var isEraser = false
    @State private var activeCategory: String? = nil
    @State private var currentBrushName: String = "Pen"
    @State private var showSizePanel = false
    @State private var showExitConfirmation = false
    
    // Photo to Canvas
    @State private var customBackgroundImage: UIImage? = nil
    @State private var selectedPhotoItem: PhotosPickerItem? = nil
    @State private var isProcessingPhoto = false
    
    // Time-Lapse
    @ObservedObject private var recorder = TimeLapseRecorder.shared
    @State private var isExportingVideo = false
    @State private var showExportSuccess = false
    
    // Canvas Customization
    @State private var canvasBackgroundColor: Color = .white
    private let bgOptions: [Color] = [.white, Color(white: 0.9), Color(white: 0.2), .black]
    
    // Canvas Customization
    @State private var canvasBackground: CanvasBackground = .solid(.white)
    @State private var showBackgroundFlyout = false
    
    enum CanvasBackground: Equatable {
        case solid(Color)
        case gradient([Color])
    }
    
    private let backgroundSolidOptions: [Color] = [.white, Color(white: 0.9), Color(white: 0.2), .black, .pink.opacity(0.2), .blue.opacity(0.2)]
    private let backgroundGradientOptions: [[Color]] = [
        [.orange, .purple],
        [.blue, .teal],
        [.indigo, .black],
        [.yellow, .red]
    ]
    
    private var ageConfig: AgeGroupConfig {
        AgeManager.shared.config(for: category.ageGroup)
    }
    
    var filteredCategories: [String] {
        ["Basic", "Sketch", "Paint", "Ink", "Maquillage", "Shine", "Magic", "Patterns", "Stickers", "Mélangeur"]
            .filter { ageConfig.toolCategories.contains($0) }
    }
    
    var filteredColors: [Color] {
        ageConfig.availableColors.isEmpty ? gridColors : ageConfig.availableColors
    }
    
    static let toolGroups: [String: [(name: String, icon: String, type: PKInkingTool.InkType, width: CGFloat, opacity: CGFloat)]] = [
        "Basic": [
            ("Marker", "pencil.tip", .marker, 15, 1.0),
            ("Pencil", "pencil", .pen, 5, 0.8),
            ("Spray", "cloud.fill", .marker, 30, 0.4),
            ("Brush", "paintbrush.fill", .pen, 20, 0.7),
            ("Magic Wand", "sparkles", .pen, 10, 1.0)
        ],
        "Sketch": [
            ("Charcoal", "square.stack.3d.up.fill", .marker, 40, 0.3),
            ("Soft Pencil", "pencil.and.outline", .pen, 3, 0.6),
            ("Graphite", "pencil.circle", .pen, 8, 0.9)
        ],
        "Paint": [
            ("Oil Brush", "paintbrush.pointed.fill", .pen, 25, 0.9),
            ("Water Color", "drop.fill", .marker, 50, 0.2),
            ("Roller", "square.grid.3x1.below.line.grid.1x2", .marker, 60, 0.8),
            ("Sponge", "circle.dotted", .marker, 45, 0.5)
        ],
        "Ink": [
            ("Fountain Pen", "fountainpen.tip", .pen, 2, 1.0),
            ("Calligraphy", "scribble", .pen, 12, 1.0),
            ("Technical", "pencil.tip.crop.circle", .pen, 1, 1.0)
        ],
        "Magic": [
            ("Neon Glow", "lightbulb.fill", .pen, 15, 0.5),
            ("Glitter", "sparkles", .marker, 20, 1.0),
            ("Rainbow", "rainbow", .pen, 25, 1.0)
        ],
        "Patterns": [
            ("Dots", "circle.grid.2x2.fill", .marker, 30, 0.6),
            ("Stars", "star.circle.fill", .pen, 20, 0.8),
            ("Checkered", "square.grid.2x2.fill", .marker, 40, 0.5)
        ],
        "Shine": [
            ("Crystal", "diamond.fill", .pen, 10, 1.0),
            ("Gold", "bitcoinsign.circle.fill", .pen, 15, 1.0)
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
    
    let gridColors: [Color] = [
        .red, .orange, .yellow, .green, .blue, .purple, .pink, .brown, .black, .gray,
        .white, .cyan, .mint, .indigo, .teal
    ]
    
    private var isPro: Bool {
        ageConfig.theme == .professional
    }
    
    var body: some View {
        ZStack {
            // 1. Theme-based Background
            if isPro {
                Color(white: 0.12).ignoresSafeArea()
                // Subtle artist grid or texture
                Canvas { context, size in
                    for x in stride(from: 0, to: size.width, by: 40) {
                        context.stroke(Path(CGRect(x: x, y: 0, width: 0.5, height: size.height)), with: .color(.white.opacity(0.05)))
                    }
                    for y in stride(from: 0, to: size.height, by: 40) {
                        context.stroke(Path(CGRect(x: 0, y: y, width: size.width, height: 0.5)), with: .color(.white.opacity(0.05)))
                    }
                }.ignoresSafeArea()
            } else {
                Color(red: 0.6, green: 0.9, blue: 1.0).ignoresSafeArea()
                DoodleBackgroundView().opacity(0.1).ignoresSafeArea()
            }
            
            HStack(spacing: 0) {
                leftSidebar
                    .padding(.leading, 15) // Safe padding from edge
                mainCanvasArea
                rightSidebar
                    .padding(.trailing, 15) // Safe padding from edge
            }
            
            // --- OVERLAYS ---
            colorPickerOverlay
            sizePickerOverlay
            exitConfirmationOverlay
            
            if isExportingVideo {
                ZStack {
                    Color.black.opacity(0.6).ignoresSafeArea()
                    VStack(spacing: 20) {
                        ProgressView().scaleEffect(2).tint(.white)
                        Text(LocalizedStringKey("Exporting Time-Lapse..."))
                            .foregroundColor(.white)
                            .font(.headline)
                    }
                }
            }
        }
        .alert(LocalizedStringKey("Video Saved!"), isPresented: $showExportSuccess) {
            Button(LocalizedStringKey("OK"), role: .cancel) { }
        } message: {
            Text(LocalizedStringKey("Your speed-paint video has been saved to your Photos."))
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            loadGroupState()
            
            // Load existing drawing if resuming
            if let artwork = existingArtwork {
                existingId = artwork.id
                if let drawing = GalleryManager.shared.getDrawing(for: artwork) {
                    canvasView.drawing = drawing
                }
            }
            
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: .landscape))
            }
        }
        .onChange(of: selectedColor) { saveGroupState() }
        .onChange(of: currentBrushName) { saveGroupState() }
        .onChange(of: currentWidth) { saveGroupState() }
        .onChange(of: activeCategory) { saveGroupState() }
        .onChange(of: selectedPhotoItem) { _, newItem in
            guard let item = newItem else { return }
            isProcessingPhoto = true
            item.loadTransferable(type: Data.self) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let data?):
                        if let uiImage = UIImage(data: data) {
                            ImageToSketchConverter.shared.convertToLineArt(image: uiImage) { sketch in
                                if let sketch = sketch {
                                    self.customBackgroundImage = sketch
                                }
                                self.isProcessingPhoto = false
                            }
                        } else {
                            self.isProcessingPhoto = false
                        }
                    case .success(nil), .failure:
                        self.isProcessingPhoto = false
                    }
                }
            }
        }
    }
    
    // MARK: - Persistence
    private func saveGroupState() {
        let group = ProfileManager.shared.currentProfile.ageGroup ?? .toddlers
        let key = "AgeGroupState_\(group.rawValue)"
        
        let stateData: [String: Any] = [
            "color": selectedColor.toHex() ?? "#000000",
            "brushName": currentBrushName,
            "width": Double(currentWidth),
            "opacity": Double(currentOpacity),
            "category": activeCategory ?? "Basic"
        ]
        UserDefaults.standard.set(stateData, forKey: key)
    }
    
    private func loadGroupState() {
        let group = ProfileManager.shared.currentProfile.ageGroup ?? .toddlers
        let key = "AgeGroupState_\(group.rawValue)"
        
        if let stateData = UserDefaults.standard.dictionary(forKey: key) {
            if let hex = stateData["color"] as? String { selectedColor = Color(hex: hex) }
            if let bName = stateData["brushName"] as? String { currentBrushName = bName }
            if let w = stateData["width"] as? Double { currentWidth = CGFloat(w) }
            if let o = stateData["opacity"] as? Double { currentOpacity = CGFloat(o) }
            if let c = stateData["category"] as? String { activeCategory = c }
            
            // Sync PencilKit tool type
            let currentCat = activeCategory ?? "Basic"
            if let groupTools = ColoringCanvasView.toolGroups[currentCat],
               let tool = groupTools.first(where: { $0.name == currentBrushName }) {
                selectedTool = tool.type
            }
        } else {
            // Initial setup based on age group defaults
            currentWidth = ageConfig.defaultWidth
            if let firstColor = filteredColors.first {
                selectedColor = firstColor
            }
            activeCategory = filteredCategories.first
            currentBrushName = "Pen" // Fallback
        }
        updateTool()
    }
    
    @ViewBuilder
    private var leftSidebar: some View {
        let brushWidth: CGFloat = isPro ? 65 : 85
        let brushHeight: CGFloat = isPro ? 44 : 55
        
        HStack(spacing: 0) {
            // 1. Vertical Category Selector (Sleek Bar)
            VStack(spacing: 15) {
                if filteredCategories.count > 1 {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 12) {
                            ForEach(filteredCategories, id: \.self) { cat in
                                Button {
                                    withAnimation(.spring()) { activeCategory = cat }
                                    AudioManager.shared.playPop()
                                } label: {
                                    Image(systemName: CategoryIcon.iconName(for: cat))
                                        .font(.system(size: isPro ? 18 : 22, weight: .bold))
                                        .foregroundColor(activeCategory == cat ? .white : (isPro ? .white.opacity(0.4) : .black.opacity(0.3)))
                                        .frame(width: isPro ? 40 : 48, height: isPro ? 40 : 48)
                                        .background(
                                            Circle()
                                                .fill(activeCategory == cat ? Color.blue : (isPro ? Color.white.opacity(0.1) : Color.black.opacity(0.05)))
                                        )
                                }
                            }
                        }
                        .padding(.vertical, 10)
                    }
                }
            }
            .frame(width: isPro ? 50 : 60)
            .background(isPro ? Color.black.opacity(0.2) : Color.white.opacity(0.1))
            
            // 2. Brushes for the Active Category
            VStack(spacing: 0) {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: isPro ? 12 : 15) {
                        let currentCat = activeCategory ?? filteredCategories.first ?? "Basic"
                        let tools = ColoringCanvasView.toolGroups[currentCat] ?? []
                        
                        ForEach(tools, id: \.name) { tool in
                            GameBrushButton(
                                tool: tool,
                                isSelected: currentBrushName == tool.name,
                                selectedColor: selectedColor,
                                width: brushWidth,
                                height: brushHeight,
                                side: .left,
                                isPro: isPro
                            ) {
                                currentBrushName = tool.name
                                selectedTool = tool.type
                                currentWidth = tool.width
                                currentOpacity = tool.opacity
                                isEraser = false
                                updateTool()
                                AudioManager.shared.playPop()
                            }
                        }
                    }
                    .padding(.vertical, 20)
                }
            }
            .frame(width: brushWidth + (isPro ? 10 : 20))
            .offset(x: isPro ? 0 : -15) 
        }
        .frame(width: isPro ? 115 : 150)
        .onAppear {
            if activeCategory == nil {
                activeCategory = filteredCategories.first
            }
        }
    }
    
    @ViewBuilder
    private var mainCanvasArea: some View {
        GeometryReader { geo in
            let bSize = min(max(geo.size.height * 0.1, 40), 55)
            VStack(spacing: 5) {
                ZStack(alignment: .top) {
                    PencilKitView(canvasView: $canvasView)
                        .background(backgroundView) // Fix: Ensure background is applied to the canvas area
                        .clipShape(RoundedRectangle(cornerRadius: 30))
                        .shadow(color: .black.opacity(0.1), radius: 10)
                        .simultaneousGesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { _ in
                                    withAnimation(.spring()) { 
                                        showColorFlyout = false
                                        showBackgroundFlyout = false
                                        showSizeFlyout = false
                                    }
                                }
                        )
                    
                    if let bgImage = customBackgroundImage {
                        Image(uiImage: bgImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .padding(40)
                            .allowsHitTesting(false)
                            .opacity(0.5)
                    } else if drawingItem.exampleImage == nil {
                        // Show template guide ONLY for regular drawings (where exampleImage is nil)
                        Image(uiImage: UIImage(named: drawingItem.imageName) ?? UIImage(systemName: drawingItem.imageName) ?? UIImage())
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .padding(40)
                            .allowsHitTesting(false)
                            .opacity(0.3)
                    }
                    if isProcessingPhoto {
                        ZStack {
                            Color.black.opacity(0.4).cornerRadius(30)
                            ProgressView()
                                .scaleEffect(2.0)
                                .tint(.white)
                        }
                    }
                }
                
                if !isPro {
                    HStack(spacing: 40) {
                        Spacer()
                        WideUtilityButton(icon: "arrow.uturn.backward", color: Color.orange.opacity(0.8), width: bSize * 1.8, height: bSize * 1.0) {
                            canvasView.undoManager?.undo()
                            AudioManager.shared.playPop()
                        }
                        WideUtilityButton(icon: "arrow.uturn.forward", color: Color.orange.opacity(0.8), width: bSize * 1.8, height: bSize * 1.0) {
                            canvasView.undoManager?.redo()
                            AudioManager.shared.playPop()
                        }
                        Spacer()
                    }
                    .padding(.bottom, 10)
                } else {
                    professionalControlsOverlay
                }
            }
        }
        .padding(.top, isPro ? 5 : 25)
        .padding(.bottom, 5)
        .padding(.horizontal, isPro ? 0 : 10)
    }
    
    @ViewBuilder
    private var backgroundView: some View {
        switch canvasBackground {
        case .solid(let color):
            color
        case .gradient(let colors):
            LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }
    
    @ViewBuilder
    private var rightSidebar: some View {
        GeometryReader { geo in
            let bSize = min(max(geo.size.height * 0.12, 50), 75) // Increased max size for iPad
            VStack(spacing: geo.size.height * 0.035) {
                HeaderCircleButton(icon: "xmark", color: .red, size: bSize) {
                    AudioManager.shared.playPop()
                    withAnimation(.spring()) { showExitConfirmation = true }
                }
                
                Divider().frame(width: 25).background(Color.white.opacity(0.3))
                
                Button {
                    isEraser = true
                    currentBrushName = "Eraser"
                    canvasView.tool = PKEraserTool(.bitmap, width: currentWidth)
                    AudioManager.shared.playPop()
                } label: {
                    ZStack {
                        Circle()
                            .fill(isEraser ? Color.blue.opacity(0.15) : Color.white.opacity(0.9))
                            .frame(width: bSize, height: bSize)
                            .shadow(radius: 3)
                        Image(systemName: "eraser.fill")
                            .font(.system(size: bSize * 0.45, weight: .bold))
                            .foregroundColor(isEraser ? .blue : .gray)
                    }
                    .overlay(Circle().stroke(Color.white, lineWidth: 3))
                }
                .scaleEffect(isEraser ? 1.15 : 1.0)
                
                Button {
                    withAnimation(.spring()) {
                        showColorFlyout.toggle()
                        showSizeFlyout = false
                    }
                    AudioManager.shared.playPop()
                } label: {
                    ZStack {
                        Circle().fill(AngularGradient(gradient: Gradient(colors: [.red, .yellow, .green, .blue, .purple, .red]), center: .center))
                        Image(systemName: "eyedropper").foregroundColor(.white).font(.system(size: bSize * 0.35, weight: .bold))
                    }
                    .frame(width: bSize, height: bSize)
                    .overlay(Circle().stroke(Color.white, lineWidth: 3))
                    .overlay(Circle().stroke(Color.blue, lineWidth: showColorFlyout ? 4 : 0))
                    .shadow(radius: 5)
                }
                Divider().frame(width: 25).background(Color.white.opacity(0.3))
                
                // Photo Import & Background Button - Only visible in Custom/Personalize mode
                if drawingItem.exampleImage == "personalize" {
                    // Background Style Button
                    Button {
                        withAnimation(.spring()) {
                            showBackgroundFlyout.toggle()
                            showColorFlyout = false
                        }
                        AudioManager.shared.playPop()
                    } label: {
                        ZStack {
                            backgroundView
                            Image(systemName: "paintpalette.fill")
                                .foregroundColor(.gray)
                                .font(.system(size: bSize * 0.35))
                        }
                        .frame(width: bSize, height: bSize)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white, lineWidth: 3))
                        .shadow(radius: 5)
                    }
                    .overlay(alignment: .trailing) {
                        if showBackgroundFlyout {
                            HStack(spacing: 12) {
                                // Solids
                                ForEach(backgroundSolidOptions, id: \.self) { color in
                                    Button {
                                        canvasBackground = .solid(color)
                                        AudioManager.shared.playPop()
                                    } label: {
                                        Circle().fill(color)
                                            .frame(width: 40, height: 40)
                                            .overlay(Circle().stroke(Color.white, lineWidth: 2))
                                            .shadow(radius: 2)
                                    }
                                }
                                
                                Divider().frame(height: 30)
                                
                                // Gradients
                                ForEach(backgroundGradientOptions, id: \.self) { colors in
                                    Button {
                                        canvasBackground = .gradient(colors)
                                        AudioManager.shared.playPop()
                                    } label: {
                                        Circle().fill(LinearGradient(colors: colors, startPoint: .top, endPoint: .bottom))
                                            .frame(width: 40, height: 40)
                                            .overlay(Circle().stroke(Color.white, lineWidth: 2))
                                            .shadow(radius: 2)
                                    }
                                }
                            }
                            .padding(10)
                            .background(Color.white.opacity(0.95))
                            .clipShape(Capsule())
                            .shadow(radius: 10)
                            .offset(x: -bSize * 1.5 - 200) // Adjust offset to show flyout
                            .transition(.move(edge: .trailing).combined(with: .opacity))
                        }
                    }
                    
                    PhotosPicker(selection: $selectedPhotoItem, matching: .images, photoLibrary: .shared()) {
                        ZStack {
                            Circle().fill(Color.purple.opacity(0.8))
                            Image(systemName: "camera.fill")
                                .foregroundColor(.white)
                                .font(.system(size: bSize * 0.4, weight: .bold))
                        }
                        .frame(width: bSize, height: bSize)
                        .overlay(Circle().stroke(Color.white, lineWidth: 3))
                        .shadow(radius: 5)
                    }
                    .disabled(isProcessingPhoto)
                }
                
                // Time-Lapse Button
                Button(action: {
                    if recorder.isRecording {
                        isExportingVideo = true
                        recorder.stopAndExport { url in
                            isExportingVideo = false
                            if let url = url {
                                UISaveVideoAtPathToSavedPhotosAlbum(url.path, nil, nil, nil)
                                showExportSuccess = true
                            }
                        }
                    } else {
                        // Correctly load the image (Asset or SystemName)
                        let bgImage: UIImage? = {
                            if let custom = customBackgroundImage { return custom }
                            // Fix: Don't use the camera icon as a background in the video if we are in personalize mode
                            if drawingItem.exampleImage == "personalize" { return nil }
                            return UIImage(named: drawingItem.imageName) ?? UIImage(systemName: drawingItem.imageName)
                        }()
                        
                        let colors: [Color] = {
                            switch canvasBackground {
                            case .solid(let c): return [c]
                            case .gradient(let cs): return cs
                            }
                        }()
                        
                        recorder.startRecording(canvas: canvasView, background: bgImage, bgColors: colors)
                    }
                    AudioManager.shared.playPop()
                }) {
                    ZStack {
                        Circle().fill(recorder.isRecording ? Color.red : Color.gray.opacity(0.8))
                        Image(systemName: recorder.isRecording ? "stop.fill" : "video.fill")
                            .foregroundColor(.white)
                            .font(.system(size: bSize * 0.4, weight: .bold))
                    }
                    .frame(width: bSize, height: bSize)
                    .overlay(Circle().stroke(Color.white, lineWidth: 3))
                    .shadow(radius: 5)
                }
                .overlay(
                    Group {
                        if recorder.isRecording {
                            Circle()
                                .stroke(Color.red, lineWidth: 2)
                                .scaleEffect(1.2)
                                .opacity(0.5)
                        }
                    }
                )
                
                if !isPro {
                    VStack(spacing: 25) {
                        ForEach([8, 28, 65], id: \.self) { size in
                            Button {
                                currentWidth = CGFloat(size)
                                updateTool()
                                AudioManager.shared.playPop()
                            } label: {
                                let dotSize = CGFloat(min(size / 3 + 14, 38))
                                ZStack {
                                    Circle()
                                        .fill(selectedColor.opacity(currentWidth == CGFloat(size) ? 1.0 : 0.8))
                                        .frame(width: dotSize, height: dotSize)
                                        .overlay(Circle().stroke(Color.white, lineWidth: currentWidth == CGFloat(size) ? 4 : 0))
                                        .overlay(Circle().stroke(Color.black.opacity(0.8), lineWidth: 2))
                                        .shadow(color: .black.opacity(0.1), radius: 2)
                                }
                            }
                            .scaleEffect(currentWidth == CGFloat(size) ? 1.1 : 1.0)
                        }
                    }
                    .padding(.vertical, 20)
                    .padding(.horizontal, 10)
                    .background(Capsule().fill(Color.black.opacity(0.04)))
                }
                
                Spacer()
            }
            .padding(.vertical, 20)
            .padding(.trailing, isPro ? 0 : 5)
            .frame(width: bSize + (isPro ? 10 : 20))
        }
        .frame(width: isPro ? 85 : 95)
    }
    
    @ViewBuilder
    private var professionalControlsOverlay: some View {
        HStack(spacing: 15) {
            // Undo
            WideUtilityButton(icon: "arrow.uturn.backward", color: Color.white.opacity(0.15), width: 55, height: 35) {
                canvasView.undoManager?.undo()
                AudioManager.shared.playPop()
            }
            
            // Width Slider
            HStack(spacing: 8) {
                Image(systemName: "line.horizontal.3").foregroundColor(.white.opacity(0.6)).font(.system(size: 12))
                Slider(value: $currentWidth, in: 1...80)
                    .tint(.blue)
                    .frame(width: 120)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 5)
            .background(.ultraThinMaterial)
            .cornerRadius(12)
            
            // Opacity Slider
            HStack(spacing: 8) {
                Image(systemName: "circle.lefthalf.filled").foregroundColor(.white.opacity(0.6)).font(.system(size: 12))
                Slider(value: $currentOpacity, in: 0.1...1.0)
                    .tint(.blue)
                    .frame(width: 120)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 5)
            .background(.ultraThinMaterial)
            .cornerRadius(12)
            
            // Redo
            WideUtilityButton(icon: "arrow.uturn.forward", color: Color.white.opacity(0.15), width: 55, height: 35) {
                canvasView.undoManager?.redo()
                AudioManager.shared.playPop()
            }
        }
        .padding(.bottom, 5)
        .onChange(of: currentWidth) { updateTool() }
        .onChange(of: currentOpacity) { updateTool() }
    }
    
    @ViewBuilder
    private var exitConfirmationOverlay: some View {
        if showExitConfirmation {
            ZStack {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture { withAnimation { showExitConfirmation = false } }
                
                VStack(spacing: 30) {
                    Text(LocalizedStringKey("Exit drawing?"))
                        .font(.system(size: 28, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(radius: 5)
                    
                    HStack(spacing: 50) {
                        Button {
                            AudioManager.shared.playPop()
                            withAnimation(.spring()) { showExitConfirmation = false }
                        } label: {
                            VStack(spacing: 10) {
                                ZStack {
                                    Circle().fill(Color.white).frame(width: 100, height: 100)
                                    Image(systemName: "xmark.circle.fill")
                                        .resizable()
                                        .frame(width: 80, height: 80)
                                        .foregroundColor(.red)
                                }
                                .shadow(color: .black.opacity(0.2), radius: 10)
                                Text(LocalizedStringKey("No")).font(.system(size: 20, weight: .bold)).foregroundColor(.white)
                            }
                        }
                        
                        Button {
                            AudioManager.shared.playSuccess()
                            saveAndExit()
                        } label: {
                            VStack(spacing: 10) {
                                ZStack {
                                    Circle().fill(Color.white).frame(width: 100, height: 100)
                                    Image(systemName: "face.smiling.fill")
                                        .resizable()
                                        .frame(width: 80, height: 80)
                                        .foregroundColor(.green)
                                }
                                .shadow(color: .black.opacity(0.2), radius: 10)
                                Text(LocalizedStringKey("Yes")).font(.system(size: 20, weight: .bold)).foregroundColor(.white)
                            }
                        }
                    }
                }
                .padding(40)
                .background(RoundedRectangle(cornerRadius: 40).fill(.ultraThinMaterial))
                .padding(20)
                .transition(.scale.combined(with: .opacity))
            }
        }
    }
    
    @ViewBuilder
    private var colorPickerOverlay: some View {
        if showColorFlyout {
            let colorsToShow: [Color] = [
                .red, .blue, .green, .yellow, .orange, .purple, .pink, .cyan, .brown,
                .black, .gray, .white, .indigo, .mint, .teal, .pink.opacity(0.8),
                Color(red: 0.5, green: 0.8, blue: 1), Color(red: 1, green: 0.8, blue: 0.5)
            ]
            
            VStack(spacing: 12) {
                if ageConfig.theme == .professional {
                    ColorPicker("", selection: $selectedColor)
                        .labelsHidden()
                        .padding(.top, 10)
                        .onChange(of: selectedColor) { updateTool() }
                    
                    Divider().background(Color.white.opacity(0.3)).padding(.horizontal, 10)
                }
                
                ScrollView(showsIndicators: false) {
                    LazyVGrid(columns: [GridItem(.fixed(35)), GridItem(.fixed(35))], spacing: 15) {
                        ForEach(colorsToShow, id: \.self) { color in
                            Button {
                                selectedColor = color
                                updateTool()
                                withAnimation { showColorFlyout = false }
                                AudioManager.shared.playPop()
                            } label: {
                                Circle()
                                    .fill(color)
                                    .frame(width: 35, height: 35)
                                    .overlay(Circle().stroke(Color.white, lineWidth: selectedColor == color ? 4 : 1.5))
                                    .shadow(color: .black.opacity(0.15), radius: 3)
                            }
                        }
                    }
                    .padding(.vertical, 15)
                }
            }
            .frame(width: 100, height: 280)
            .background(RoundedRectangle(cornerRadius: 35).fill(.ultraThinMaterial))
            .shadow(color: .black.opacity(0.15), radius: 10)
            .padding(.leading, 105) 
            .padding(.bottom, 60)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
            .transition(.asymmetric(insertion: .move(edge: .leading).combined(with: .opacity), removal: .opacity.combined(with: .scale(scale: 0.9))))
        }
    }
    
    @ViewBuilder
    private var sizePickerOverlay: some View {
        if showSizeFlyout {
            VStack(spacing: 15) {
                Text(LocalizedStringKey("Size")).font(.caption.bold()).foregroundColor(.gray)
                Circle().fill(selectedColor).frame(width: currentWidth, height: currentWidth).frame(width: 50, height: 50).background(Circle().stroke(Color.gray.opacity(0.2), lineWidth: 1))
                Slider(value: $currentWidth, in: 2...80).accentColor(.blue).frame(width: 150).rotationEffect(.degrees(-90)).frame(height: 160).onChange(of: currentWidth) { updateTool() }
                Button(LocalizedStringKey("Done")) { withAnimation { showSizeFlyout = false } }.font(.caption2.bold()).foregroundColor(.blue)
            }
            .padding(.vertical, 15)
            .frame(width: 80)
            .background(RoundedRectangle(cornerRadius: 30).fill(.ultraThinMaterial))
            .shadow(color: .black.opacity(0.15), radius: 10)
            .padding(.leading, 105)
            .padding(.bottom, 120)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
            .transition(.asymmetric(insertion: .move(edge: .leading).combined(with: .opacity), removal: .opacity.combined(with: .scale(scale: 0.9))))
        }
    }
    
    func updateTool() {
        let colorWithOpacity = UIColor(selectedColor).withAlphaComponent(currentOpacity)
        canvasView.tool = PKInkingTool(selectedTool, color: colorWithOpacity, width: currentWidth)
    }
    
    @MainActor
    func saveAndExit() {
        let drawingImage = canvasView.drawing.image(from: canvasView.bounds, scale: 1.0)
        let templateImage = UIImage(systemName: drawingItem.imageName) ?? UIImage()
        let size = canvasView.bounds.size
        let renderer = UIGraphicsImageRenderer(size: size)
        let compositeImage = renderer.image { context in
            UIColor.white.setFill()
            context.fill(CGRect(origin: .zero, size: size))
            let templateSize = CGSize(width: 300, height: 300)
            let templateRect = CGRect(x: (size.width - templateSize.width) / 2, y: (size.height - templateSize.height) / 2, width: templateSize.width, height: templateSize.height)
            templateImage.withTintColor(.black.withAlphaComponent(0.8)).draw(in: templateRect)
            drawingImage.draw(in: CGRect(origin: .zero, size: size))
        }
        GalleryManager.shared.saveArtwork(image: compositeImage, drawing: canvasView.drawing, category: category.name, drawingItemName: drawingItem.imageName, profileId: ProfileManager.shared.currentProfile.id, existingId: existingId)
        ProfileManager.shared.addStar()
        dismiss()
    }
}

enum SidebarSide { case left, right }

struct GameBrushButton: View {
    let tool: ToolConfig
    let isSelected: Bool
    let selectedColor: Color
    let width: CGFloat
    let height: CGFloat
    var side: SidebarSide = .right
    let isPro: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            if isPro {
                // Professional Stroke Preview Button
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isSelected ? Color.white.opacity(0.15) : Color.white.opacity(0.05))
                        .frame(width: width, height: height)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(isSelected ? selectedColor : Color.white.opacity(0.1), lineWidth: isSelected ? 3 : 1)
                        )
                    
                    // The Stroke Preview
                    ToolStrokePreview(
                        type: tool.type,
                        color: isSelected ? selectedColor : .white,
                        width: tool.width,
                        opacity: tool.opacity
                    )
                    .frame(width: width * 0.7, height: height * 0.6)
                }
                .scaleEffect(isSelected ? 1.05 : 1.0)
            } else {
                // Playful Game Pencil Style
                ZStack(alignment: side == .left ? .trailing : .leading) {
                    HStack(spacing: 0) {
                        if side == .right { tipView }
                        RoundedRectangle(cornerRadius: 8)
                            .fill(isSelected ? selectedColor.gradient : Color.white.opacity(0.8).gradient)
                            .frame(width: width - 30)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.black.opacity(0.8), lineWidth: 2))
                        if side == .left { tipView.rotationEffect(.degrees(180)) }
                    }
                    
                    Image(systemName: tool.icon)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(isSelected ? .white : .black.opacity(0.5))
                        .offset(x: side == .left ? -15 : 45)
                }
                .frame(width: width, height: height)
                .offset(x: isSelected ? (side == .left ? 25 : -25) : 0)
                .shadow(color: .black.opacity(0.1), radius: 5, x: side == .left ? 5 : -5, y: 5)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
    private var tipView: some View {
        ZStack {
            // Tip body
            Path { path in
                path.move(to: CGPoint(x: 30, y: 6))
                path.addLine(to: CGPoint(x: 10, y: height/2))
                path.addLine(to: CGPoint(x: 30, y: height-6))
                path.closeSubpath()
            }
            .fill(Color(white: 0.95))
            
            // Actual colored tip
            Path { path in
                path.move(to: CGPoint(x: 20, y: height/2 - 4))
                path.addArc(center: CGPoint(x: 10, y: height/2), radius: 5, startAngle: .degrees(-90), endAngle: .degrees(90), clockwise: true)
                path.closeSubpath()
            }
            .fill(isSelected ? selectedColor : Color.gray.opacity(0.3))
        }
        .frame(width: 30)
        .overlay(Path { path in
            path.move(to: CGPoint(x: 30, y: 6))
            path.addLine(to: CGPoint(x: 10, y: height/2))
            path.addLine(to: CGPoint(x: 30, y: height-6))
        }.stroke(Color.black.opacity(0.7), lineWidth: 1.5))
    }
}

struct ToolStrokePreview: View {
    let type: PKInkingTool.InkType
    let color: Color
    let width: CGFloat
    let opacity: CGFloat
    
    var body: some View {
        Canvas { context, size in
            var path = Path()
            path.move(to: CGPoint(x: size.width * 0.1, y: size.height * 0.5))
            path.addCurve(to: CGPoint(x: size.width * 0.9, y: size.height * 0.5),
                         control1: CGPoint(x: size.width * 0.4, y: size.height * 0.1),
                         control2: CGPoint(x: size.width * 0.6, y: size.height * 0.9))
            
            // Scale width for preview (smaller as requested)
            var previewWidth = min(width / 5 + 2, size.height * 0.3)
            var style = StrokeStyle(lineWidth: previewWidth, lineCap: .round, lineJoin: .round)
            var finalOpacity = opacity
            
            // Differentiate by InkType to match canvas appearance
            switch type {
            case .pencil, .crayon:
                style.dash = [1, 2] // Textured look
                previewWidth = min(previewWidth, 3)
                style.lineWidth = previewWidth
            case .marker:
                style.lineCap = .butt // Flat marker tip
                previewWidth *= 1.3
                style.lineWidth = previewWidth
            case .pen, .fountainPen:
                previewWidth = min(previewWidth, 4)
                style.lineWidth = previewWidth
            case .watercolor:
                previewWidth *= 1.5
                style.lineWidth = previewWidth
                finalOpacity *= 0.6 // More transparent
            default:
                break
            }
            
            context.stroke(path, with: .color(color.opacity(finalOpacity)), style: style)
        }
    }
}

struct WideUtilityButton: View {
    let icon: String
    let color: Color
    var width: CGFloat = 80
    var height: CGFloat = 46
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: height * 0.3).fill(color.gradient)
                Image(systemName: icon).font(.system(size: height * 0.45).bold()).foregroundColor(.white)
            }
            .frame(width: width, height: height)
            .overlay(RoundedRectangle(cornerRadius: height * 0.3).stroke(Color.white.opacity(0.5), lineWidth: height * 0.05))
            .shadow(radius: 5)
        }
    }
}

struct CategoryIcon: View {
    let name: String
    var icon: String? = nil
    let isSelected: Bool
    var size: CGFloat = 60
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon ?? CategoryIcon.iconName(for: name)).font(.system(size: size * 0.35, weight: .semibold))
                Text(LocalizedStringKey(name)).font(.system(size: size * 0.15, weight: .bold))
            }
            .frame(width: size, height: size)
            .background(isSelected ? Color.blue.opacity(0.1) : Color.clear)
            .cornerRadius(size * 0.25)
            .foregroundColor(isSelected ? .blue : .gray)
            .scaleEffect(isSelected ? 1.1 : 1.0)
        }
    }
    static func iconName(for name: String) -> String {
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
