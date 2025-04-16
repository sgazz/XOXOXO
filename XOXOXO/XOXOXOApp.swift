//
//  XOXOXOApp.swift
//  XOXOXO
//
//  Created by Gazza on 15. 4. 2025..
//

import SwiftUI

@main
struct XOXOXOApp: App {
    // Користимо ову променљиву за иницијализацију ресурса током стартовања
    @State private var isFirstLaunch = true
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    if isFirstLaunch {
                        // Прва иницијализација ресурса (звукова, итд.)
                        setupResources()
                        isFirstLaunch = false
                    }
                }
        }
    }
    
    private func setupResources() {
        // Pre-load звучних ефеката за бољи перформанс
        preloadSounds()
    }
    
    private func preloadSounds() {
        // Прелоадујемо све звукове да би били спремни
        for sound in GameSound.allCases {
            SoundManager.shared.preloadSound(sound)
        }
    }
}
