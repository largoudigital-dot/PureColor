//
//  PureColorApp.swift
//  PureColor
//
//  Created by Largou on 03.05.26.
//

import SwiftUI

@main
struct PureColorApp: App {
    @StateObject private var languageManager = LanguageManager.shared
    @StateObject private var screenTimeManager = ScreenTimeManager.shared
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                AgeSelectionView()
                    .onAppear {
                        AudioManager.shared.playBackgroundMusic()
                    }
                
                if screenTimeManager.isTimeUp {
                    ScreenTimeGateView()
                        .transition(.opacity)
                }
            }
            .animation(.easeInOut, value: screenTimeManager.isTimeUp)
            .environmentObject(languageManager)
            .environmentObject(screenTimeManager)
            .environment(\.locale, languageManager.locale) // Applying the manual locale
        }
    }
}
