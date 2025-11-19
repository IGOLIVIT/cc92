//
//  SettingsView.swift
//  Neon Jump
//
//  Created by IGOR on 17/11/2025.
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @State private var showingResetAlert = false
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            // Background
            Color(hex: "050505")
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(Color(hex: "F9FF14"))
                            .frame(width: 44, height: 44)
                    }
                    
                    Spacer()
                    
                    Text("Settings")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(Color(hex: "F9FF14"))
                    
                    Spacer()
                    
                    Color.clear
                        .frame(width: 44, height: 44)
                }
                .padding(.horizontal)
                .padding(.top, 20)
                .padding(.bottom, 30)
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Statistics Section
                        SettingsSection(title: "Statistics") {
                            VStack(spacing: 16) {
                                StatisticRow(title: "High Score", value: "\(viewModel.playerStats.highScore)")
                                
                                Divider()
                                    .background(Color.white.opacity(0.1))
                                
                                StatisticRow(title: "Games Played", value: "\(viewModel.playerStats.gamesPlayed)")
                                
                                Divider()
                                    .background(Color.white.opacity(0.1))
                                
                                StatisticRow(title: "Total Jumps", value: "\(viewModel.playerStats.totalJumps)")
                                
                                Divider()
                                    .background(Color.white.opacity(0.1))
                                
                                StatisticRow(title: "Power-ups Collected", value: "\(viewModel.playerStats.powerUpsCollected)")
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white.opacity(0.05))
                            )
                        }
                        
                        // Reset Section
                        SettingsSection(title: "Data Management") {
                            Button(action: {
                                showingResetAlert = true
                            }) {
                                HStack {
                                    Image(systemName: "arrow.counterclockwise")
                                        .font(.system(size: 18, weight: .bold))
                                    
                                    Text("Reset Game Data")
                                        .font(.system(size: 16, weight: .semibold))
                                    
                                    Spacer()
                                }
                                .foregroundColor(.red)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.red.opacity(0.1))
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationBarHidden(true)
        .alert("Reset Game Data", isPresented: $showingResetAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                viewModel.resetGameData()
            }
        } message: {
            Text("Are you sure you want to reset all game data? This will erase your progress, scores, and statistics. This action cannot be undone.")
        }
    }
}

struct SettingsSection<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title.uppercased())
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.white.opacity(0.5))
                .padding(.horizontal, 4)
            
            content
        }
    }
}

struct StatisticRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.white.opacity(0.8))
            
            Spacer()
            
            Text(value)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(Color(hex: "F9FF14"))
        }
    }
}

// SettingsViewModel
import Combine

class SettingsViewModel: ObservableObject {
    @Published var playerStats: PlayerModel
    
    private let dataService = GameDataService.shared
    
    init() {
        self.playerStats = dataService.loadPlayerData()
    }
    
    func resetGameData() {
        dataService.resetAllData()
        playerStats = PlayerModel()
        
        // Post notification to refresh other views
        NotificationCenter.default.post(name: NSNotification.Name("GameDataReset"), object: nil)
    }
}

