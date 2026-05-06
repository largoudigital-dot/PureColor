import SwiftUI

struct HeaderCircleButton: View {
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(color.gradient)
                
                Image(systemName: icon)
                    .font(.system(size: 20).bold())
                    .foregroundColor(.white)
            }
            .frame(width: 50, height: 50)
            .overlay(Circle().stroke(Color.white, lineWidth: 3))
            .shadow(radius: 5)
        }
    }
}

struct HeaderSquareButton: View {
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(color.gradient)
                
                Image(systemName: icon)
                    .font(.system(size: 18).bold())
                    .foregroundColor(.white)
            }
            .frame(width: 46, height: 46)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.5), lineWidth: 2))
            .shadow(radius: 5)
        }
    }
}
