//
//  NeonJumpApp.swift
//  Neon Jump
//
//  Created by IGOR on 17/11/2025.
//

import SwiftUI

@main
struct NeonJumpApp: App {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    
    var body: some Scene {
        WindowGroup {
            if hasCompletedOnboarding {
                ContentView()
            } else {
                OnboardingView()
            }
        }
    }
}


