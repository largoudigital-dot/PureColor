import SwiftUI

struct DoodleBackgroundView: View {
    var body: some View {
        ZStack {
            ForEach(0..<15) { i in
                Image(systemName: randomIcon())
                    .font(.system(size: CGFloat.random(in: 40...120)))
                    .foregroundColor(.white.opacity(0.3))
                    .rotationEffect(.degrees(Double.random(in: 0...360)))
                    .position(
                        x: CGFloat.random(in: 0...1200),
                        y: CGFloat.random(in: 0...900)
                    )
            }
        }
    }
    
    func randomIcon() -> String {
        let icons = ["pencil.tip", "paintpalette.fill", "paintbrush.fill", "pencil.and.outline", "star.fill", "heart.fill", "circle.fill"]
        return icons.randomElement() ?? "star.fill"
    }
}
