import SwiftUI

struct LayerExplanationView: View {
    @State private var bodyColor: Color = .gray.opacity(0.2)
    @State private var leafColor: Color = .gray.opacity(0.2)
    @State private var stemColor: Color = .gray.opacity(0.2)
    
    var body: some View {
        VStack(spacing: 40) {
            Text("How Layers Work (Procreate)")
                .font(.title.bold())
            
            // The "Composite" Image
            ZStack {
                // Layer 1: The Body (from PNG 1)
                Circle()
                    .fill(bodyColor)
                    .frame(width: 200, height: 180)
                    .offset(y: 20)
                    .onTapGesture { bodyColor = .red }
                
                // Layer 2: The Stem (from PNG 2)
                Rectangle()
                    .fill(stemColor)
                    .frame(width: 15, height: 40)
                    .offset(y: -70)
                    .onTapGesture { stemColor = .brown }

                // Layer 3: The Leaf (from PNG 3)
                Ellipse()
                    .fill(leafColor)
                    .frame(width: 60, height: 30)
                    .rotationEffect(.degrees(-30))
                    .offset(x: 30, y: -75)
                    .onTapGesture { leafColor = .green }
                
                // Layer 4: The Outline (Always on top, from PNG 4)
                Circle()
                    .stroke(Color.black, lineWidth: 4)
                    .frame(width: 200, height: 180)
                    .offset(y: 20)
                    .allowsHitTesting(false) // Let taps pass through to colors
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 20).stroke(Color.gray.opacity(0.3)))
            
            VStack(alignment: .leading, spacing: 15) {
                LayerInfoRow(number: 1, text: "Outline (Top Layer - Transparent PNG)")
                LayerInfoRow(number: 2, text: "Leaf (Separate PNG)")
                LayerInfoRow(number: 3, text: "Stem (Separate PNG)")
                LayerInfoRow(number: 4, text: "Body (Separate PNG)")
            }
            .padding()
            
            Text("Tap the parts above to color them!")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Spacer()
        }
        .padding()
    }
}

struct LayerInfoRow: View {
    let number: Int
    let text: String
    var body: some View {
        HStack {
            Text("\(number)")
                .font(.caption.bold())
                .foregroundColor(.white)
                .frame(width: 24, height: 24)
                .background(Circle().fill(Color.blue))
            Text(text)
                .font(.subheadline)
        }
    }
}

#Preview {
    LayerExplanationView()
}
