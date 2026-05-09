import SwiftUI

struct ParentalGateView: View {
    @Environment(\.dismiss) var dismiss
    let onVerified: () -> Void
    
    @State private var num1 = Int.random(in: 1...12)
    @State private var num2 = Int.random(in: 1...12)
    @State private var options: [Int] = []
    @State private var selectedWrong: Int? = nil
    
    var body: some View {
        ZStack {
            // Premium Blurred Background
            Rectangle()
                .fill(.ultraThinMaterial)
                .overlay(Color.black.opacity(0.2))
                .ignoresSafeArea()
                .onTapGesture { dismiss() }
            
            VStack(spacing: 20) {
                // Header (Compact)
                VStack(spacing: 4) {
                    Text(LocalizedStringKey("Parents Only"))
                        .font(.system(size: 22, weight: .black, design: .rounded))
                        .foregroundColor(.blue)
                    
                    Text(LocalizedStringKey("Solve to continue"))
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(.gray)
                }
                
                // Math Question (Compact)
                Text("\(num1) + \(num2) = ?")
                    .font(.system(size: 36, weight: .black, design: .rounded))
                    .foregroundColor(.black)
                
                // MULTIPLE CHOICE OPTIONS (Smaller Buttons)
                HStack(spacing: 15) {
                    ForEach(options, id: \.self) { option in
                        Button {
                            verify(option)
                        } label: {
                            Text("\(option)")
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                .foregroundColor(selectedWrong == option ? .white : .blue)
                                .frame(width: 70, height: 70)
                                .background(
                                    RoundedRectangle(cornerRadius: 15)
                                        .fill(selectedWrong == option ? Color.red : Color.white)
                                        .shadow(color: .black.opacity(0.08), radius: 5, y: 3)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 15)
                                        .stroke(Color.blue.opacity(0.1), lineWidth: 1.5)
                                )
                        }
                    }
                }
                
                Button(LocalizedStringKey("Cancel")) {
                    dismiss()
                }
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.gray.opacity(0.7))
            }
            .padding(.vertical, 25)
            .padding(.horizontal, 40)
            .background(
                RoundedRectangle(cornerRadius: 25)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.15), radius: 20)
            )
            .frame(maxWidth: 400) // Keep it small and centered
            .padding(20)
        }
        .onAppear {
            generateOptions()
        }
    }
    
    private func generateOptions() {
        let correct = num1 + num2
        var set = Set<Int>()
        set.insert(correct)
        while set.count < 3 {
            let offset = Int.random(in: -5...5)
            let wrong = correct + offset
            if wrong > 0 && wrong != correct { set.insert(wrong) }
        }
        options = Array(set).shuffled()
    }
    
    private func verify(_ choice: Int) {
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
        if choice == (num1 + num2) {
            onVerified()
            dismiss()
        } else {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.2)) {
                selectedWrong = choice
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                selectedWrong = nil
                num1 = Int.random(in: 1...12); num2 = Int.random(in: 1...12)
                generateOptions()
            }
        }
    }
}

#Preview {
    ParentalGateView { print("Verified!") }
}
