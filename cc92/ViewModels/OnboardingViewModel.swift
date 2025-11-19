//
//  OnboardingViewModel.swift
//  Neon Jump
//
//  Created by IGOR on 17/11/2025.
//

import SwiftUI
import Combine

class OnboardingViewModel: ObservableObject {
    @Published var currentPage = 0
    
    let pages: [OnboardingPage] = [
        OnboardingPage(
            title: "Welcome!",
            description: "Experience the thrill of jumping through neon platforms in this exciting arcade game!",
            icon: "bolt.fill"
        ),
        OnboardingPage(
            title: "Tap & Hold to Jump",
            description: "Press and hold on the screen to charge your jump. Release to launch! The longer you hold, the higher you jump.",
            icon: "hand.tap.fill"
        ),
        OnboardingPage(
            title: "Collect Power-ups",
            description: "Grab power-ups to gain special abilities: Double Points, Shield, and Slow Motion!",
            icon: "star.fill"
        ),
        OnboardingPage(
            title: "Beat Your High Score",
            description: "Compete against yourself and track your progress. Every jump counts!",
            icon: "trophy.fill"
        )
    ]
    
    var isLastPage: Bool {
        currentPage == pages.count - 1
    }
    
    func nextPage() {
        if currentPage < pages.count - 1 {
            currentPage += 1
        }
    }
    
    func previousPage() {
        if currentPage > 0 {
            currentPage -= 1
        }
    }
}

struct OnboardingPage: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let icon: String
}

