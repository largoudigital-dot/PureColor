import SwiftUI

struct HeaderCircleButton: View {
    let icon: String
    let color: Color
    var size: CGFloat = 50
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(color.gradient)
                
                Image(systemName: icon)
                    .font(.system(size: size * 0.45).bold())
                    .foregroundColor(.white)
            }
            .frame(width: size, height: size)
            .overlay(Circle().stroke(Color.white, lineWidth: size * 0.08))
            .shadow(radius: 5)
        }
    }
}

struct HeaderSquareButton: View {
    let icon: String
    let color: Color
    var size: CGFloat = 46
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: size * 0.25)
                    .fill(color.gradient)
                
                Image(systemName: icon)
                    .font(.system(size: size * 0.4).bold())
                    .foregroundColor(.white)
            }
            .frame(width: size, height: size)
            .overlay(RoundedRectangle(cornerRadius: size * 0.25).stroke(Color.white.opacity(0.5), lineWidth: size * 0.05))
            .shadow(radius: 5)
        }
    }
}


