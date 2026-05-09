import SwiftUI
import Combine

class ScreenTimeManager: ObservableObject {
    static let shared = ScreenTimeManager()
    
    // Time limits in seconds (e.g. 20 min = 1200)
    @Published var selectedLimit: TimeInterval = 0 // 0 means no limit
    @Published var timeRemaining: TimeInterval = 0
    @Published var isTimeUp: Bool = false
    
    private var timer: Timer?
    
    private init() {
        // Load saved screen time limit
        let savedLimit = UserDefaults.standard.double(forKey: "screen_time_limit")
        selectedLimit = savedLimit
        timeRemaining = savedLimit
        
        // Listen for background/foreground transitions to pause/resume timer correctly if needed
    }
    
    func startTimer(limitInMinutes: Double) {
        let limitInSeconds = limitInMinutes * 60
        selectedLimit = limitInSeconds
        timeRemaining = limitInSeconds
        UserDefaults.standard.set(limitInSeconds, forKey: "screen_time_limit")
        
        isTimeUp = false
        timer?.invalidate()
        
        if limitInSeconds > 0 {
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
                self?.tick()
            }
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func tick() {
        DispatchQueue.main.async {
            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
            } else {
                self.stopTimer()
                self.isTimeUp = true
            }
        }
    }
    
    func unlockWithParentalGate() {
        isTimeUp = false
        timeRemaining = 0
        selectedLimit = 0
        UserDefaults.standard.set(0.0, forKey: "screen_time_limit")
    }
    
    // Helper to format remaining time for UI
    var formattedTimeRemaining: String {
        let minutes = Int(timeRemaining) / 60
        let seconds = Int(timeRemaining) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
