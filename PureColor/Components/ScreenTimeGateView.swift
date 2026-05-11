import SwiftUI

struct ScreenTimeGateView: View {
    @ObservedObject var timeManager = ScreenTimeManager.shared
    @State private var password = ""
    @State private var showError = false
    
    var body: some View {
        ZStack {
            // Background blur or color to block the app
            Color.black.opacity(0.85).ignoresSafeArea()
            
            VStack(spacing: 30) {
                Image(systemName: "clock.badge.exclamationmark.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.orange)
                
                Text(LocalizedStringKey("Time is Up!"))
                    .font(.system(size: 40, weight: .heavy, design: .rounded))
                    .foregroundColor(.white)
                
                Text(LocalizedStringKey("Ask your parents to unlock more time."))
                    .font(.title2)
                    .foregroundColor(.white.opacity(0.8))
                
                VStack(spacing: 15) {
                    SecureField(LocalizedStringKey("Parent Password (e.g., 1234)"), text: $password)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(15)
                        .frame(width: 300)
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)
                        .keyboardType(.numberPad)
                    
                    if showError {
                        Text(LocalizedStringKey("Incorrect password"))
                            .foregroundColor(.red)
                            .font(.callout.bold())
                    }
                    
                    Button {
                        // Simple mock password for now: 1234
                        if password == "1234" {
                            AudioManager.shared.playSuccess()
                            timeManager.unlockWithParentalGate()
                        } else {
                            AudioManager.shared.playPop() // error sound
                            showError = true
                        }
                    } label: {
                        Text(LocalizedStringKey("Unlock App"))
                            .font(.title3.bold())
                            .foregroundColor(.white)
                            .padding(.horizontal, 40)
                            .padding(.vertical, 15)
                            .background(Color.orange.gradient)
                            .cornerRadius(25)
                            .shadow(radius: 5)
                    }
                }
                .padding(.top, 20)
            }
            .padding(40)
            .background(
                RoundedRectangle(cornerRadius: 30)
                    .fill(Color.gray.opacity(0.2))
                    .background(Material.ultraThin)
            )
            .clipShape(RoundedRectangle(cornerRadius: 30))
        }
    }
}
