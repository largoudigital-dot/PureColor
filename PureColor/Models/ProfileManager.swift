import SwiftUI
import Combine

struct UserProfile: Identifiable, Codable {
    let id: UUID
    var name: String
    var avatar: String
    var ageGroup: AgeGroup? // New: Link profile to an age group
    var stars: Int
    var lastDailyRewardClaimed: Date?
    var collectedStickers: [String]
    
    static var defaultProfile: UserProfile {
        UserProfile(id: UUID(), name: "Guest", avatar: "person.circle.fill", ageGroup: nil, stars: 0, lastDailyRewardClaimed: nil, collectedStickers: [])
    }
}

class ProfileManager: ObservableObject {
    static let shared = ProfileManager()
    
    @Published var profiles: [UserProfile] = []
    @Published var currentProfileIndex: Int = 0
    
    var currentProfile: UserProfile {
        get {
            if profiles.isEmpty {
                let defaultP = UserProfile.defaultProfile
                profiles = [defaultP]
                return defaultP
            }
            return profiles[currentProfileIndex]
        }
        set {
            profiles[currentProfileIndex] = newValue
            save()
        }
    }
    
    private init() {
        load()
    }
    
    func save() {
        if let encoded = try? JSONEncoder().encode(profiles) {
            UserDefaults.standard.set(encoded, forKey: "user_profiles")
        }
    }
    
    func load() {
        if let data = UserDefaults.standard.data(forKey: "user_profiles"),
           let decoded = try? JSONDecoder().decode([UserProfile].self, from: data) {
            profiles = decoded
        } else {
            profiles = [UserProfile.defaultProfile]
        }
    }
    
    func addStar() {
        currentProfile.stars += 1
        save()
    }
}
