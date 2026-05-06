import SwiftUI
import PencilKit

struct ColoringCanvasView: View {
    let category: Category
    let drawingItem: DrawingItem
    @Environment(\.dismiss) var dismiss
    
    // PencilKit State
    @State private var canvasView = PKCanvasView()
    
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
    
    let proColors: [Color] = [
        .black, .gray, .red, .orange, .yellow, .green, .blue, .indigo, .purple, .pink, .brown
    ]
    
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
        "Mélangeur": [
            ("Blender", "circle.dotted.circle", .pen, 20, 0.2),
            ("Mixer", "wind.snow", .marker, 30, 0.1)
        ]
    ]
    
    @State private var currentWidth: CGFloat = 10
    @State private var currentOpacity: CGFloat = 1.0
    @State private var showColorFlyout = false
    
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
                // LEFT SIDEBAR (All Controls)
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
                    
                    // TRASH (Delete everything) - MOVED HERE
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
                    
                    // DONE (Check) - MOVED HERE
                    HeaderCircleButton(icon: "checkmark", color: isLocked ? .gray : .green) {
                        if !isLocked { saveAndExit(); AudioManager.shared.playSuccess() }
                    }
                    .disabled(isLocked)
                    .scaleEffect(0.9)
                }
                .padding(.vertical, 20)
                .padding(.leading, 10)
                .frame(width: 70)
                
                // CENTER: CANVAS AREA
                ZStack {
                    RoundedRectangle(cornerRadius: 30)
                        .fill(Color.white)
                        .shadow(color: .black.opacity(0.1), radius: 10)
                    
                    PencilKitView(canvasView: $canvasView)
                        .cornerRadius(30)
                    
                    Image(systemName: drawingItem.imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 300, height: 300)
                        .foregroundColor(.black.opacity(0.8))
                        .allowsHitTesting(false)
                        .opacity(0.9)
                    
                    // Size Slider Tooltip (Floating)
                    if showSizePanel {
                        VStack {
                            Text("Size: \(Int(brushWidth))").font(.caption2.bold()).foregroundColor(.white).padding(5).background(Capsule().fill(Color.black.opacity(0.5)))
                            Slider(value: $brushWidth, in: 1...80) { _ in updateTool() }
                                .accentColor(.white)
                                .frame(width: 150)
                                .rotationEffect(.degrees(-90))
                        }
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 15).fill(.ultraThinMaterial))
                        .offset(x: 100)
                    }
                }
                .padding(.top, 40)
                .padding(.bottom, 20)
                .padding(.horizontal, 10)
                
                // RIGHT SIDEBAR (ADVANCED CATEGORIES ONLY)
                VStack(spacing: 12) {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 12) {
                            // Category Icons
                            ForEach(["Basic", "Sketch", "Paint", "Ink", "Maquillage", "Shine", "Mélangeur"], id: \.self) { category in
                                CategoryIcon(name: category, isSelected: activeCategory == category) {
                                    withAnimation(.spring()) {
                                        activeCategory = (activeCategory == category) ? nil : category
                                    }
                                }
                            }
                            
                            // Eraser (Static)
                            CategoryIcon(name: "Eraser", icon: "eraser.fill", isSelected: isEraser) {
                                isEraser = true
                                activeCategory = nil
                                showColorFlyout = false
                                canvasView.tool = PKEraserTool(.bitmap, width: brushWidth)
                                AudioManager.shared.playPop()
                            }
                            
                            Divider().padding(.horizontal, 15)
                            
                            // COLOR PICKER BUTTON
                            Button {
                                withAnimation(.spring()) {
                                    showColorFlyout.toggle()
                                    activeCategory = nil
                                }
                                AudioManager.shared.playPop()
                            } label: {
                                VStack(spacing: 4) {
                                    ZStack {
                                        Circle().fill(AngularGradient(gradient: Gradient(colors: [.red, .yellow, .green, .blue, .purple, .red]), center: .center))
                                        Image(systemName: "eyedropper").foregroundColor(.white).font(.system(size: 14, weight: .bold))
                                    }
                                    .frame(width: 45, height: 45)
                                    .overlay(Circle().stroke(Color.blue, lineWidth: showColorFlyout ? 3 : 0))
                                    Text("Colors").font(.system(size: 8, weight: .bold))
                                }
                            }
                            .padding(.bottom, 10)
                        }
                        .padding(.vertical, 15)
                    }
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
            
            // --- OVERLAY: Fly-out Sub-menu (TRUE OVERLAY) ---
            if let category = activeCategory {
                VStack(spacing: 10) {
                    Text(category).font(.caption.bold()).foregroundColor(.gray)
                    
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 8) {
                            if let groupTools = toolGroups[category] {
                                ForEach(groupTools, id: \.name) { tool in
                                    Button {
                                        currentBrushName = tool.name
                                        selectedTool = tool.type
                                        currentWidth = tool.width
                                        currentOpacity = tool.opacity
                                        isEraser = false
                                        updateTool()
                                        withAnimation { activeCategory = nil; showColorFlyout = false }
                                        AudioManager.shared.playPop()
                                    } label: {
                                        VStack(spacing: 4) {
                                            Image(systemName: tool.icon)
                                                .font(.system(size: 22))
                                            Text(tool.name).font(.system(size: 8, weight: .medium))
                                        }
                                        .frame(width: 65, height: 65)
                                        .background(currentBrushName == tool.name ? Color.blue.opacity(0.1) : Color.white)
                                        .cornerRadius(15)
                                        .shadow(color: .black.opacity(0.05), radius: 2)
                                        .foregroundColor(currentBrushName == tool.name ? .blue : .black)
                                    }
                                }
                            }
                        }
                        .padding(.vertical, 10)
                    }
                }
                .frame(width: 85)
                .background(RoundedRectangle(cornerRadius: 30).fill(.ultraThinMaterial))
                .shadow(color: .black.opacity(0.1), radius: 10)
                .padding(.trailing, 105) // Puts it exactly next to the sidebar
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .opacity.combined(with: .scale(scale: 0.9))
                ))
            }
            
            // --- OVERLAY: Color Fly-out (NEW) ---
            if showColorFlyout {
                VStack(spacing: 12) {
                    Text("Pick a Color").font(.caption.bold()).foregroundColor(.gray)
                    
                    ScrollView(showsIndicators: false) {
                        LazyVGrid(columns: [GridItem(.fixed(30)), GridItem(.fixed(30))], spacing: 12) {
                            ForEach(gridColors, id: \.self) { color in
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
                .padding(.bottom, 60) // Positioned above the Colors button
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .opacity.combined(with: .scale(scale: 0.9))
                ))
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            updateTool()
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: .landscape))
            }
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
        let image = canvasView.drawing.image(from: canvasView.bounds, scale: 1.0)
        GalleryManager.shared.saveArtwork(image: image, category: category.name, profileId: ProfileManager.shared.currentProfile.id)
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
