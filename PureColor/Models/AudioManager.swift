import SwiftUI
import AVFoundation
import Combine

class AudioManager: ObservableObject {
    static let shared = AudioManager()
    
    private var musicPlayer: AVAudioPlayer?
    private var effectPlayer: AVAudioPlayer?
    
    @AppStorage("musicEnabled") var musicEnabled = true {
        didSet {
            if musicEnabled {
                playBackgroundMusic()
            } else {
                stopBackgroundMusic()
            }
        }
    }
    
    @AppStorage("soundEnabled") var soundEnabled = true
    
    private init() {}
    
    func playBackgroundMusic() {
        guard musicEnabled else { return }
        
        // Note: You need to add 'background_music.mp3' to your project resources
        guard let url = Bundle.main.url(forResource: "background_music", withExtension: "mp3") else {
            print("Audio: Background music file not found")
            return
        }
        
        do {
            musicPlayer = try AVAudioPlayer(contentsOf: url)
            musicPlayer?.numberOfLoops = -1 // Loop infinitely
            musicPlayer?.volume = 0.4
            musicPlayer?.play()
        } catch {
            print("Audio: Could not play background music: \(error.localizedDescription)")
        }
    }
    
    func stopBackgroundMusic() {
        musicPlayer?.stop()
    }
    
    func playSoundEffect(_ name: String) {
        guard soundEnabled else { return }
        
        // Note: Add sound files like 'click.mp3', 'sparkle.mp3', etc.
        guard let url = Bundle.main.url(forResource: name, withExtension: "mp3") else {
            // Optional: Use a system sound as fallback if file is missing
            let systemSoundID: SystemSoundID = 1104 // Standard click
            AudioServicesPlaySystemSound(systemSoundID)
            return
        }
        
        do {
            effectPlayer = try AVAudioPlayer(contentsOf: url)
            effectPlayer?.play()
        } catch {
            print("Audio: Could not play sound effect \(name): \(error.localizedDescription)")
        }
    }
    
    func playSuccess() {
        playSoundEffect("success")
    }
    
    func playPop() {
        playSoundEffect("pop")
    }
}
