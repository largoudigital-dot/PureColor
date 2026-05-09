import SwiftUI

struct StickerCard: View {
    let category: Category
    @State private var isPressed = false
    
    var body: some View {
        VStack(spacing: 12) {
            // Icon Container (Looks like a sticker)
            ZStack {
                // Outer Glow/Border
                Circle()
                    .fill(Color.white)
                    .frame(width: 100, height: 100)
                    .shadow(color: category.color.opacity(0.3), radius: 10, x: 0, y: 5)
                
                Circle()
                    .fill(category.color.opacity(0.1))
                    .frame(width: 85, height: 85)
                
                Image(systemName: category.icon)
                    .font(.system(size: 45, weight: .bold))
                    .foregroundColor(category.color)
            }
            
            // Text with playful background
            Text(LocalizedStringKey(category.name))
                .font(.system(size: 22, weight: .black, design: .rounded))
                .foregroundColor(.primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(category.color.opacity(0.15))
                )
        }
        .padding(20)
        .background(
            ZStack {
                // The "Wobbly" Background
                RoundedRectangle(cornerRadius: 40, style: .continuous)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.05), radius: 15, x: 0, y: 10)
            }
        )
        .scaleEffect(isPressed ? 0.92 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        .onLongPressGesture(minimumDuration: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
}

#Preview {
    ZStack {
        Color.gray.opacity(0.1).ignoresSafeArea()
        StickerCard(category: mockCategories[2])
    }
}
