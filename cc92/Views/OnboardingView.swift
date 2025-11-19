//
//  OnboardingView.swift
//  Neon Jump
//
//  Created by IGOR on 17/11/2025.
//

import SwiftUI

struct OnboardingView: View {
    @StateObject private var viewModel = OnboardingViewModel()
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    
    var body: some View {
        ZStack {
            // Background
            Color(hex: "050505")
                .ignoresSafeArea()
            
            VStack(spacing: 40) {
                // Header
                HStack {
                    if viewModel.currentPage > 0 {
                        Button(action: {
                            withAnimation {
                                viewModel.previousPage()
                            }
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(Color(hex: "F9FF14"))
                                .frame(width: 44, height: 44)
                        }
                    } else {
                        Color.clear
                            .frame(width: 44, height: 44)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        hasCompletedOnboarding = true
                    }) {
                        Text("Skip")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color(hex: "F9FF14").opacity(0.7))
                    }
                }
                .padding(.horizontal)
                .padding(.top, 20)
                
                // Content
                TabView(selection: $viewModel.currentPage) {
                    ForEach(0..<viewModel.pages.count, id: \.self) { index in
                        OnboardingPageView(page: viewModel.pages[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                
                // Page Indicator
                HStack(spacing: 8) {
                    ForEach(0..<viewModel.pages.count, id: \.self) { index in
                        Circle()
                            .fill(index == viewModel.currentPage ? Color(hex: "F9FF14") : Color(hex: "F9FF14").opacity(0.3))
                            .frame(width: 8, height: 8)
                    }
                }
                .padding(.bottom, 20)
                
                // Button
                Button(action: {
                    if viewModel.isLastPage {
                        hasCompletedOnboarding = true
                    } else {
                        withAnimation {
                            viewModel.nextPage()
                        }
                    }
                }) {
                    Text(viewModel.isLastPage ? "Get Started" : "Next")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Color(hex: "050505"))
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(hex: "F9FF14"))
                                .shadow(color: Color(hex: "F9FF14").opacity(0.5), radius: 10, x: 0, y: 4)
                        )
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 40)
            }
        }
    }
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // Icon
            ZStack {
                Circle()
                    .fill(Color(hex: "F9FF14").opacity(0.1))
                    .frame(width: 160, height: 160)
                
                Circle()
                    .fill(Color(hex: "F9FF14").opacity(0.2))
                    .frame(width: 130, height: 130)
                
                Image(systemName: page.icon)
                    .font(.system(size: 60, weight: .bold))
                    .foregroundColor(Color(hex: "F9FF14"))
            }
            
            // Title
            Text(page.title)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(Color(hex: "F9FF14"))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            // Description
            Text(page.description)
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .lineSpacing(6)
                .padding(.horizontal, 40)
            
            Spacer()
        }
    }
}

// Color extension for hex colors
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

