import SwiftUI
import Combine

struct CategoryCard: View {
    let category: Category
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(category.color.opacity(0.2))
                    .frame(width: 80, height: 80)
                
                Image(systemName: category.icon)
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(category.color)
            }
            
            VStack(spacing: 4) {
                Text(category.name)
                    .font(.system(size: 20, weight: .heavy, design: .rounded))
                    .foregroundColor(.primary)
                
                Text("\(category.drawings.count) Pages")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(Color(UIColor.systemBackground))
                .shadow(color: category.color.opacity(0.1), radius: 10, x: 0, y: 5)
        )
        .scaleEffect(isAnimating ? 1 : 0.8)
        .opacity(isAnimating ? 1 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7, blendDuration: 0)) {
                isAnimating = true
            }
        }
    }
}

#Preview {
    CategoryCard(category: mockCategories[0])
        .padding()
        .background(Color.gray.opacity(0.1))
}
